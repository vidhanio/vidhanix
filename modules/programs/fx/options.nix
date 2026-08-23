{
  flake.aspects.fx = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.fx;
        json = pkgs.formats.json { };

        mkResourceOption =
          { dir, description }:
          lib.mkOption {
            type = lib.types.either (lib.types.attrsOf (
              lib.types.oneOf [
                lib.types.lines
                lib.types.path
                lib.types.str
              ]
            )) lib.types.path;
            default = { };
            description = ''
              ${description}

              Either an attribute set of resources or a path to a directory,
              symlinked to {file}`~/.fx/${dir}/`.
            '';
          };

        normalizeDirectory =
          name: option: source:
          if lib.isPath source then
            source
          else
            pkgs.runCommandLocal name { } ''
              source=${lib.escapeShellArg (toString source)}
              if [[ ! -d "$source" ]]; then
                echo ${lib.escapeShellArg "programs.fx.${option} must be a directory"} >&2
                exit 1
              fi
              ln -s "$source" "$out"
            '';

        normalizeSkill =
          source:
          pkgs.runCommandLocal "fx-skill" { } ''
            source=${lib.escapeShellArg (toString source)}
            if [[ -d "$source" ]]; then
              ln -s "$source" "$out"
            elif [[ -f "$source" ]]; then
              mkdir "$out"
              ln -s "$source" "$out/SKILL.md"
            else
              echo "skill source must be a file or directory: $source" >&2
              exit 1
            fi
          '';

        resourceFiles =
          dir: suffix: resources:
          let
            attrs = if lib.isAttrs resources then resources else { };
          in
          (lib.optionalAttrs (lib.hm.strings.isPathLike resources) {
            ".fx/${dir}" = {
              source = normalizeDirectory "fx-${dir}" dir resources;
              recursive = true;
            };
          })
          // lib.mapAttrs' (
            name: content:
            if lib.isPath content && lib.pathIsDirectory content then
              lib.nameValuePair ".fx/${dir}/${name}" {
                source = content;
                recursive = true;
              }
            else if dir == "skills" && lib.hm.strings.isPathLike content && !lib.isPath content then
              lib.nameValuePair ".fx/${dir}/${name}" {
                source = normalizeSkill content;
                recursive = true;
              }
            else
              lib.nameValuePair ".fx/${dir}/${name}${suffix}" (
                if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
              )
          ) attrs;

        resourceAssertion =
          { dir, resources }:
          {
            assertion = !lib.isPath resources || lib.pathIsDirectory resources;
            message = "`programs.fx.${dir}` must be a directory when set to a path";
          };

        toFxServer =
          server:
          let
            isRemote = (server.url or null) != null;
            renderedEnv = lib.hm.mcp.renderEnv (path: "{file:${path}}") (server.env or { });
          in
          {
            type = if isRemote then "http" else "local";
          }
          // (
            if isRemote then
              {
                inherit (server) url;
              }
              // lib.optionalAttrs ((server.headers or { }) != { }) {
                inherit (server) headers;
              }
            else
              {
                command = [ server.command ] ++ (server.args or [ ]);
              }
              // lib.optionalAttrs (renderedEnv != { }) {
                environment = renderedEnv;
              }
          );

        transformedMcpServers = lib.optionalAttrs (cfg.enableMcpIntegration && config.programs.mcp.enable) (
          lib.mapAttrs (
            _: server:
            lib.hm.mcp.transformMcpServer {
              inherit server;
              exclude = [
                "enabled"
                "args"
                "env"
              ];
              extraTransforms = [ toFxServer ];
            }
            // lib.optionalAttrs ((server.enabled or null) == false || (server.disabled or false)) {
              enabled = false;
            }
          ) config.programs.mcp.servers
        );

        mcpServers = transformedMcpServers // (cfg.mcp or { });
      in
      {
        options.programs.fx = {
          enable = lib.mkEnableOption "fx";

          package = lib.mkPackageOption pkgs "fx" { nullable = true; };

          enableMcpIntegration = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether to integrate the MCP servers config from
              {option}`programs.mcp.servers` into
              {option}`programs.fx.mcp`.

              Note: Servers defined in {option}`programs.mcp.servers` are merged
              with {option}`programs.fx.mcp`, with fx settings taking precedence.
            '';
          };

          settings = lib.mkOption {
            inherit (json) type;
            default = { };
            example = {
              model = "zai/glm-5.2-fast";
              permission_mode = "ask";
              effort = "auto";
              sandbox = "none";
              workspaces."/absolute/path/to/project".permission.edit."docs/*" = "allow";
            };
            description = ''
              Configuration written to {file}`~/.fx/settings.json`.

              User profile preferences, including `model`, `permission_mode`,
              `max_agent_steps`, `max_tool_result_bytes`, `effort`, `sandbox`,
              `input_appearance`, `update_channel`, `notifications`, and
              per-workspace overrides under `workspaces`.

              Project-safe fields (`max_agent_steps`, `max_tool_result_bytes`,
              `context`, `sandbox`) are ignored here and belong in the
              workspace's `.fx.json`.

              Unknown JSON keys are ignored; invalid values in known keys can
              make the profile unusable, and the file is limited to 64 KiB. See
              <https://fx.sh/docs/configure-fx/configuration>
              for the documentation.
            '';
          };

          mcp = lib.mkOption {
            inherit (json) type;
            default = { };
            example = {
              local-tools = {
                type = "local";
                command = [
                  "npx"
                  "-y"
                  "@modelcontextprotocol/server-everything"
                ];
              };
            };
            description = ''
              MCP server definitions written to {file}`~/.fx/mcp.json`'s `mcp`
              map. See <https://fx.sh/docs/capabilities/mcp> for the
              documentation.
            '';
          };

          skills = mkResourceOption {
            dir = "skills";
            description = ''
              Custom skills for fx, symlinked into {file}`~/.fx/skills/`.

              This option can either be:
              - An attribute set defining skills
              - A path to a directory containing skill folders

              If an attribute set is used, the attribute name becomes the
              skill directory name, and the value is either:
              - Inline content as a string (creates `~/.fx/skills/<name>/SKILL.md`)
              - A path to a file (creates `~/.fx/skills/<name>/SKILL.md`)
              - A path to a directory (creates `~/.fx/skills/<name>/` with all files)

              If a path is used, it is expected to contain one folder per skill
              name, each containing a {file}`SKILL.md`. The directory is
              symlinked to {file}`~/.fx/skills/`.
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

          home.file = {
            ".fx/settings.json" = lib.mkIf (cfg.settings != { }) {
              source = json.generate "fx-settings.json" cfg.settings;
            };

            ".fx/mcp.json" = lib.mkIf (mcpServers != { }) {
              source = json.generate "fx-mcp.json" { mcp = mcpServers; };
            };
          }
          // resourceFiles "skills" "/SKILL.md" cfg.skills;

          assertions = map resourceAssertion [
            {
              dir = "skills";
              resources = cfg.skills;
            }
          ];
        };
      };
  };
}
