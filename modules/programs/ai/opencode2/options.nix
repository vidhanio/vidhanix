{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.opencode2;
      jsonFormat = pkgs.formats.json { };

      toOpencode2Server =
        server:
        let
          isRemote = (server.url or null) != null;
          renderedEnv = lib.hm.mcp.renderEnv (path: "{file:${path}}") (server.env or { });
        in
        {
          type = if isRemote then "remote" else "local";
        }
        // (
          if isRemote then
            {
              inherit (server) url;
            }
            // lib.optionalAttrs ((server.headers or { }) != { }) { inherit (server) headers; }
          else
            {
              command = [ server.command ] ++ (server.args or [ ]);
            }
            // lib.optionalAttrs (renderedEnv != { }) { environment = renderedEnv; }
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
            extraTransforms = [ toOpencode2Server ];
          }
          // lib.optionalAttrs ((server.enabled or null) == false || (server.disabled or false)) {
            disabled = true;
          }
        ) config.programs.mcp.servers
      );

      mcpServers = transformedMcpServers // (cfg.settings.mcp.servers or { });

      settings =
        cfg.settings
        // lib.optionalAttrs (mcpServers != { }) {
          mcp = (cfg.settings.mcp or { }) // {
            servers = mcpServers;
          };
        };

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
            symlinked to {file}`$XDG_CONFIG_HOME/opencode/${dir}/`.
          '';
        };

      resourceFiles =
        dir: suffix: resources:
        let
          attrs = if lib.isAttrs resources then resources else { };
        in
        (lib.optionalAttrs (lib.hm.strings.isPathLike resources) {
          "opencode/${dir}" = {
            source = resources;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          if lib.hm.strings.isPathLike content && lib.pathIsDirectory content then
            lib.nameValuePair "opencode/${dir}/${name}" {
              source = content;
              recursive = true;
            }
          else
            lib.nameValuePair "opencode/${dir}/${name}${suffix}" (
              if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
            )
        ) attrs;

      resourceAssertion =
        { dir, resources }:
        {
          assertion = !lib.hm.strings.isPathLike resources || lib.pathIsDirectory resources;
          message = "`programs.opencode2.${dir}` must be a directory when set to a path";
        };
    in
    {
      options.programs.opencode2 = {
        enable = lib.mkEnableOption "OpenCode 2";

        package = lib.mkPackageOption pkgs "opencode2" {
          nullable = true;
          default = null;
        };

        enableMcpIntegration = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to integrate the MCP servers config from
            {option}`programs.mcp.servers` into
            {option}`programs.opencode2.settings.mcp.servers`.

            Note: Servers defined in {option}`programs.mcp.servers` are transformed
            into the V2 MCP server shape and merged with
            {option}`programs.opencode2.settings.mcp.servers`, with OpenCode 2
            settings taking precedence. See <https://opencode.ai/v2/docs/mcp-servers/>.
          '';
        };

        settings = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          example = {
            model = "anthropic/claude-sonnet-4-5";
            default_agent = "build";
            autoupdate = false;
            permissions = [
              {
                action = "shell";
                resource = "git push *";
                effect = "ask";
              }
            ];
            providers.openninja.models."gpt-5.2-custom" = {
              modelID = "gpt-5.2";
              name = "GPT-5.2 Custom";
            };
          };
          description = ''
            Configuration written to {file}`$XDG_CONFIG_HOME/opencode/opencode.json`.
            See <https://opencode.ai/v2/docs/config/> for the documentation.

            Deferred while {option}`programs.opencode` (V1) is enabled: the V1
            module owns the shared file, and V2 normalizes V1 fields in memory.
          '';
        };

        cli = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          example = {
            theme = {
              name = "stylix";
              mode = "dark";
            };
            keybinds.leader = "alt+b";
            scroll_speed = 2;
            mouse = true;
          };
          description = ''
            CLI/TUI configuration written to
            {file}`$XDG_CONFIG_HOME/opencode/cli.json`.

            This includes theme, keybinds, scroll settings, and other CLI-only
            options. `theme` is `{ name, mode }`; see
            <https://opencode.ai/v2/docs/themes/> for the documentation.
          '';
        };

        context = lib.mkOption {
          type = lib.types.either lib.types.lines lib.types.path;
          default = "";
          description = ''
            Global context for OpenCode 2.

            The value is either:
            - Inline content as a string
            - A path to a file containing the content

            The configured content is written to
            {file}`$XDG_CONFIG_HOME/opencode/AGENTS.md`.
          '';
          example = "Read @docs/guidelines.md before editing TypeScript code.";
        };

        agents = mkResourceOption {
          dir = "agents";
          description = ''
            Custom agent for OpenCode 2.

            This option can either be:
            - An attribute set defining agents
            - A path to a directory containing multiple agents files

            If an attribute set is used, the attribute name becomes the agent filename,
            and the value is either:
            - Inline content as a string (creates `opencode/agents/<name>.md`)
            - A path to a file (creates `opencode/agents/<name>.md`)

            If a path is used, it is expected to contain agents files.
            The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/agents/`.
          '';
        };

        commands = mkResourceOption {
          dir = "commands";
          description = ''
            Custom command for OpenCode 2.

            This option can either be:
            - An attribute set defining commands
            - A path to a directory containing multiple commands files

            If an attribute set is used, the attribute name becomes the command filename,
            and the value is either:
            - Inline content as a string (creates `opencode/commands/<name>.md`)
            - A path to a file (creates `opencode/commands/<name>.md`)

            If a path is used, it is expected to contain commands files.
            The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/commands/`.
          '';
        };

        skills = mkResourceOption {
          dir = "skills";
          description = ''
            Custom skills for OpenCode 2.

            This option can be either:
            - An attribute set defining skills
            - A path to a directory containing skill folders

            If an attribute set is used, the attribute name becomes the
            skill directory name, and the value is either:
            - Inline content as a string (creates `$XDG_CONFIG_HOME/opencode/skills/<name>/SKILL.md`)
            - A path to a file (creates `$XDG_CONFIG_HOME/opencode/skills/<name>/SKILL.md`)
            - A path to a directory (creates `$XDG_CONFIG_HOME/opencode/skills/<name>/` with all files)

            This also accepts Nix store paths, for example a skill directory from
            a package.

            If a path is used, it is expected to contain one folder per skill name,
            each containing a {file}`SKILL.md`. The directory is symlinked to
            {file}`$XDG_CONFIG_HOME/opencode/skills/`.
          '';
        };

        themes = lib.mkOption {
          type = lib.types.either (lib.types.attrsOf (lib.types.either jsonFormat.type lib.types.path)) lib.types.path;
          default = { };
          example = {
            stylix = {
              version = 2;
              dark.background.default = "#151515";
              dark.text.default = "#d0d0d0";
            };
          };
          description = ''
            Custom themes for OpenCode 2.

            This option can either be:
            - An attribute set defining themes
            - A path to a directory containing multiple theme files

            If an attribute set is used, the attribute name becomes the theme filename,
            and the value is either:
            - An attribute set that is converted to a JSON file
            - A path to a file

            If a path is used, it is expected to contain theme files.
            The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/themes/`.

            Theme files are either the native V2 format (`version` = 2, with
            `light`/`dark` modes of hue scales and semantic tokens) or the V1 format
            (a `theme` key), which OpenCode 2 migrates at runtime. A `$schema` key
            is added automatically to generated theme files.

            Set {option}`programs.opencode2.cli.theme` to enable a theme.
          '';
        };

        plugins = mkResourceOption {
          dir = "plugins";
          description = ''
            Custom plugin for OpenCode 2.

            This option can either be:
            - An attribute set defining plugins
            - A path to a directory containing multiple plugins files

            If an attribute set is used, the attribute name becomes the plugin filename,
            and the value is either:
            - Inline content as a string (creates `opencode/plugins/<name>.ts`)
            - A path to a file (creates `opencode/plugins/<name>.ts`)

            If a path is used, it is expected to contain plugins files.
            The directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/plugins/`.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

        xdg.configFile = {
          "opencode/opencode.json" =
            lib.mkIf ((cfg.settings != { } || transformedMcpServers != { }) && !config.programs.opencode.enable)
              {
                source = jsonFormat.generate "opencode2-settings.json" (
                  {
                    "$schema" = "https://opencode.ai/config.json";
                  }
                  // settings
                );
              };

          "opencode/cli.json" = lib.mkIf (cfg.cli != { }) {
            source = jsonFormat.generate "opencode2-cli.json" cfg.cli;
          };

          "opencode/AGENTS.md" = lib.mkIf (!config.programs.opencode.enable) (
            if lib.isPath cfg.context then
              { source = cfg.context; }
            else
              lib.mkIf (cfg.context != "") {
                text = cfg.context;
              }
          );
        }
        // (lib.optionalAttrs (lib.hm.strings.isPathLike cfg.themes) {
          "opencode/themes" = {
            source = cfg.themes;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          lib.nameValuePair "opencode/themes/${name}.json" (
            if lib.isPath content then
              { source = content; }
            else
              {
                source = jsonFormat.generate "opencode2-${name}.json" (
                  {
                    "$schema" = "https://opencode.ai/theme.json";
                  }
                  // content
                );
              }
          )
        ) (if lib.isAttrs cfg.themes then cfg.themes else { })
        // resourceFiles "agents" ".md" cfg.agents
        // resourceFiles "commands" ".md" cfg.commands
        // resourceFiles "skills" "/SKILL.md" cfg.skills
        // resourceFiles "plugins" ".ts" cfg.plugins;

        assertions = map resourceAssertion [
          {
            dir = "agents";
            resources = cfg.agents;
          }
          {
            dir = "commands";
            resources = cfg.commands;
          }
          {
            dir = "skills";
            resources = cfg.skills;
          }
          {
            dir = "plugins";
            resources = cfg.plugins;
          }
          {
            dir = "themes";
            resources = cfg.themes;
          }
        ];

        warnings =
          let
            invalidThemes = lib.filterAttrs (
              _name: content: lib.isAttrs content && !(content ? version) && !(content ? theme)
            ) (if lib.isAttrs cfg.themes then cfg.themes else { });
          in
          lib.optionals (invalidThemes != { }) [
            ''
              programs.opencode2.themes contains themes without a `version` (native V2)
              or `theme` (V1) key: ${lib.concatStringsSep ", " (lib.attrNames invalidThemes)}.

              OpenCode 2 only loads theme files that have one of those keys. Add
              `version = 2` to use the native V2 format, or a `theme` attribute
              set for the V1 format.
            ''
          ];
      };
    };
}
