{
  flake.aspects.prime-agent = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.prime-agent;
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
              symlinked to {file}`~/.prime/agent/${dir}/`.
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
                echo ${lib.escapeShellArg "programs.prime-agent.${option} must be a directory"} >&2
                exit 1
              fi
              ln -s "$source" "$out"
            '';

        normalizeSkill =
          source:
          pkgs.runCommandLocal "prime-agent-skill" { } ''
            source=${lib.escapeShellArg (toString source)}
            if [[ -d "$source" ]]; then
              ln -s "$source" "$out"
            elif [[ -f "$source" ]]; then
              mkdir "$out"
              ln -s "$source" "$out/SKILL.md"
            else
              echo "Prime Agent skill source must be a file or directory: $source" >&2
              exit 1
            fi
          '';

        resourceFiles =
          dir: suffix: resources:
          let
            attrs = if lib.isAttrs resources then resources else { };
          in
          (lib.optionalAttrs (lib.hm.strings.isPathLike resources) {
            ".prime/agent/${dir}" = {
              source = normalizeDirectory "prime-agent-${dir}" dir resources;
              recursive = true;
            };
          })
          // lib.mapAttrs' (
            name: content:
            if lib.isPath content && lib.pathIsDirectory content then
              lib.nameValuePair ".prime/agent/${dir}/${name}" {
                source = content;
                recursive = true;
              }
            else if dir == "skills" && lib.hm.strings.isPathLike content && !lib.isPath content then
              lib.nameValuePair ".prime/agent/${dir}/${name}" {
                source = normalizeSkill content;
                recursive = true;
              }
            else
              lib.nameValuePair ".prime/agent/${dir}/${name}${suffix}" (
                if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
              )
          ) attrs;

        resourceAssertion =
          { dir, resources }:
          {
            assertion = !lib.isPath resources || lib.pathIsDirectory resources;
            message = "`programs.prime-agent.${dir}` must be a directory when set to a path";
          };

        toPrimeAgentServer =
          name: server:
          lib.hm.mcp.transformMcpServer {
            inherit server;
            exclude = [ "enabled" ];
            extraTransforms = [
              lib.hm.mcp.addType
              (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; })
            ];
          }
          // lib.optionalAttrs ((server.enabled or null) == false || (server.disabled or false)) {
            enabled = false;
          };

        transformedMcpServers = lib.optionalAttrs (cfg.enableMcpIntegration && config.programs.mcp.enable) (
          lib.mapAttrs toPrimeAgentServer config.programs.mcp.servers
        );

        mcpServers = transformedMcpServers // (cfg.settings.mcpServers or { });

        settings =
          cfg.settings
          // lib.optionalAttrs (mcpServers != { }) {
            inherit mcpServers;
          };
      in
      {
        options.programs.prime-agent = {
          enable = lib.mkEnableOption "Prime Agent";

          package = lib.mkPackageOption pkgs "prime-agent" { nullable = true; };

          enableMcpIntegration = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether to integrate the MCP servers config from
              {option}`programs.mcp.servers` into
              {option}`programs.prime-agent.settings.mcpServers`.

              Note: Servers defined in {option}`programs.mcp.servers` are merged
              with {option}`programs.prime-agent.settings.mcpServers`, with
              prime-agent settings taking precedence.
            '';
          };

          settings = lib.mkOption {
            inherit (json) type;
            default = { };
            example = {
              model = "anthropic/claude-sonnet-4-20250514";
              sessionDir = "~/.prime/agent/sessions";
            };
            description = ''
              Configuration written to {file}`~/.prime/agent/settings.json`.
              See <https://github.com/PrimeIntellect-ai/prime-agent/blob/main/packages/coding-agent/docs/settings.md>
              for the documentation.
            '';
          };

          skills = mkResourceOption {
            dir = "skills";
            description = ''
              Custom skills for Prime Agent.

              This option can be either:
              - An attribute set defining skills
              - A path to a directory containing skill folders

              If an attribute set is used, the attribute name becomes the
              skill directory name, and the value is either:
              - Inline content as a string (creates `~/.prime/agent/skills/<name>/SKILL.md`)
              - A path to a file (creates `~/.prime/agent/skills/<name>/SKILL.md`)
              - A path to a directory (creates `~/.prime/agent/skills/<name>/` with all files)

              This also accepts Nix store paths, for example a skill directory from
              a package.

              If a path is used, it is expected to contain one folder per skill name,
              each containing a {file}`SKILL.md`. The directory is symlinked to
              {file}`~/.prime/agent/skills/`.
            '';
          };

          extensions = mkResourceOption {
            dir = "extensions";
            description = ''
              Custom extension for Prime Agent.

              This option can either be:
              - An attribute set defining extensions
              - A path to a directory containing multiple extensions files

              If an attribute set is used, the attribute name becomes the extension filename,
              and the value is either:
              - Inline content as a string (creates `prime/agent/extensions/<name>.ts`)
              - A path to a file (creates `prime/agent/extensions/<name>.ts`)

              If a path is used, it is expected to contain extensions files.
              The directory is symlinked to {file}`~/.prime/agent/extensions/`.
            '';
          };

          prompts = mkResourceOption {
            dir = "prompts";
            description = ''
              Custom prompt template for Prime Agent.

              This option can either be:
              - An attribute set defining prompt templates
              - A path to a directory containing multiple prompt templates files

              If an attribute set is used, the attribute name becomes the prompt template filename,
              and the value is either:
              - Inline content as a string (creates `prime/agent/prompts/<name>.md`)
              - A path to a file (creates `prime/agent/prompts/<name>.md`)

              If a path is used, it is expected to contain prompt templates files.
              The directory is symlinked to {file}`~/.prime/agent/prompts/`.
            '';
          };

          themes = lib.mkOption {
            type = lib.types.either (lib.types.attrsOf (lib.types.either json.type lib.types.path)) lib.types.path;
            default = { };
            example = {
              stylix = {
                name = "stylix";
                colors.accent = "#00aaff";
              };
            };
            description = ''
              Custom themes for Prime Agent.

              This option can either be:
              - An attribute set defining themes
              - A path to a directory containing multiple theme files

              If an attribute set is used, the attribute name becomes the theme filename,
              and the value is either:
              - An attribute set that is converted to a JSON file
              - A path to a file

              If a path is used, it is expected to contain theme files.
              The directory is symlinked to {file}`~/.prime/agent/themes/`.

              A `$schema` key and the theme `name` are added automatically.

              Set {option}`programs.prime-agent.settings.theme` to enable a theme.
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

          home.file = {
            ".prime/agent/settings.json" = lib.mkIf (settings != { }) {
              source = json.generate "prime-agent-settings.json" settings;
            };
          }
          // (lib.optionalAttrs (lib.hm.strings.isPathLike cfg.themes) {
            ".prime/agent/themes" = {
              source = cfg.themes;
              recursive = true;
            };
          })
          // lib.mapAttrs' (
            name: content:
            lib.nameValuePair ".prime/agent/themes/${name}.json" (
              if lib.isPath content then
                { source = content; }
              else
                {
                  source = json.generate "prime-agent-${name}.json" (
                    {
                      "$schema" =
                        "https://raw.githubusercontent.com/PrimeIntellect-ai/prime-agent/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
                      inherit name;
                    }
                    // content
                  );
                }
            )
          ) (if lib.isAttrs cfg.themes then cfg.themes else { })
          // resourceFiles "skills" "/SKILL.md" cfg.skills
          // resourceFiles "extensions" ".ts" cfg.extensions
          // resourceFiles "prompts" ".md" cfg.prompts;

          assertions = map resourceAssertion [
            {
              dir = "skills";
              resources = cfg.skills;
            }
            {
              dir = "extensions";
              resources = cfg.extensions;
            }
            {
              dir = "prompts";
              resources = cfg.prompts;
            }
            {
              dir = "themes";
              resources = cfg.themes;
            }
          ];
        };
      };
  };
}
