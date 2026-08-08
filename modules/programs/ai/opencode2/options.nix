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

      # HM server -> V2 shape (`command` array, `environment`, `{file:}` refs).
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

            This option can either be:
            - An attribute set defining resources
            - A path to a directory containing resource folders

            If an attribute set is used, the attribute name becomes the resource
            name, and the value is either:
            - Inline content as a string
            - A path to a file
            - A path to a directory

            If a path is used, it is expected to contain one folder per resource
            name. The directory is symlinked to
            {file}`$XDG_CONFIG_HOME/opencode/${dir}/`.
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

            Servers from {option}`programs.mcp.servers` are transformed into
            the V2 MCP server shape (see
            <https://opencode.ai/v2/docs/mcp-servers/>) and merged with
            {option}`programs.opencode2.settings.mcp.servers`, with OpenCode 2
            settings taking precedence.
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

            OpenCode 2 reads the same file as OpenCode 1 and normalizes supported
            V1 fields in memory, so both V1- and V2-shaped keys are accepted. The
            V2 shape is recommended; the big differences from V1 are:
            - `agent` → `agents`, `command` → `commands`, `provider` → `providers`,
              `snapshot` → `snapshots`, `attachment` → `media`, `plugin` → `plugins`
            - `permission` (grouped by tool) → one ordered `permissions` array with
              `{ action, resource, effect }` rules
            - `autoshare` → `share`, `reference` → `references`
            - MCP servers live under `mcp.servers`, `enabled` is now `disabled`
            - skills are one ordered array of paths/URLs instead of
              `{ paths, urls }`

            While {option}`programs.opencode` (V1) is enabled, this option is
            deferred: the V1 module owns the shared file, because V1 cannot
            read V2-shaped keys. Write shared settings there in the V1 shape
            (supported V1 fields are normalized by V2 in memory); V2-only keys
            have no V1 equivalent.
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

            OpenCode 2 owns this file (the background service does not read it) and
            replaces the V1 `tui.json`; it is auto-migrated from `tui.json` once on
            first start, after which `cli.json` is the source of truth. Declarative
            setups should write `cli.json` directly, which this option does.

            `theme` is `{ name, mode }`: `name` is a built-in theme or a custom
            theme written by {option}`programs.opencode2.themes` (the filename
            becomes the name), and `mode` is `"system"`, `"dark"` or `"light"`.
            See <https://opencode.ai/v2/docs/themes/> for the token reference and
            <https://opencode.ai/v2/docs/migrate-v1/#tui-configuration> for the
            field mapping from the V1 `tui.json`.
          '';
        };

        context = lib.mkOption {
          type = lib.types.either lib.types.lines lib.types.path;
          default = "";
          description = ''
            Global context for OpenCode 2, written to
            {file}`$XDG_CONFIG_HOME/opencode/AGENTS.md`.

            The value is either:
            - Inline content as a string
            - A path to a file containing the content
          '';
          example = "Read @docs/guidelines.md before editing TypeScript code.";
        };

        agents = mkResourceOption {
          dir = "agents";
          description = ''
            Custom agents for OpenCode 2, written to
            {file}`$XDG_CONFIG_HOME/opencode/agents/`.

            Markdown files use YAML frontmatter (`description`, `mode`, `model`,
            `permissions`, ...) and the body becomes the agent system prompt. The
            path below `agents/` becomes the agent ID. See
            <https://opencode.ai/v2/docs/agents/> for the documentation.

            Note that the native V2 `agents` map can also be declared directly in
            {option}`programs.opencode2.settings`.
          '';
        };

        commands = mkResourceOption {
          dir = "commands";
          description = ''
            Custom slash commands for OpenCode 2, written to
            {file}`$XDG_CONFIG_HOME/opencode/commands/`.

            The Markdown body is the command template; frontmatter supports
            `description`, `agent`, `subtask`, and `model`. See
            <https://opencode.ai/v2/docs/commands/> for the documentation.

            Note that the native V2 `commands` map can also be declared directly in
            {option}`programs.opencode2.settings`.
          '';
        };

        skills = mkResourceOption {
          dir = "skills";
          description = ''
            Custom skills for OpenCode 2, written to
            {file}`$XDG_CONFIG_HOME/opencode/skills/`.

            The directory name becomes the skill ID; each skill may carry
            supporting scripts and references next to its {file}`SKILL.md`. See
            <https://opencode.ai/v2/docs/skills/> for the documentation.

            OpenCode 2 also discovers `~/.claude/skills` and `~/.agents/skills`
            automatically, so skills installed there (e.g. through
            `programs.agent-skills`) are picked up without this option.
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
            Custom themes for OpenCode 2, written to
            {file}`$XDG_CONFIG_HOME/opencode/themes/`.

            This option can either be:
            - An attribute set defining themes
            - A path to a directory containing theme files

            If an attribute set is used, the attribute name becomes the theme
            filename (and therefore the theme name), and the value is either:
            - An attribute set that is converted to a JSON file
            - A path to a file

            If a path is used, it is expected to contain theme files. The
            directory is symlinked to {file}`$XDG_CONFIG_HOME/opencode/themes/`.

            Theme files are either the native V2 format (`version` = 2, with
            `light`/`dark` modes of hue scales and semantic tokens) or the V1
            format (a `theme` key), which OpenCode 2 migrates at runtime. A
            `$schema` key pointing at `https://opencode.ai/theme.json` is added
            automatically to generated theme files; values given here take
            precedence.

            Set {option}`programs.opencode2.cli.theme` to enable a theme.
            See <https://opencode.ai/v2/docs/themes/> for the documentation.
          '';
        };

        plugins = mkResourceOption {
          dir = "plugins";
          description = ''
            Custom OpenCode 2 plugins, written to
            {file}`$XDG_CONFIG_HOME/opencode/plugins/`.

            OpenCode 2 discovers `{plugin,plugins}/*.{ts,js,...}` from the global
            configuration directory and from project `.opencode` directories. The
            plugin API is new in V2 and still being finalized; V1 plugin code does
            not work. See <https://opencode.ai/v2/docs/config/#plugins> for the
            configuration entries and the plugins guide for development.
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
          ]
          ++
            lib.optionals
              (
                config.programs.opencode.enable
                && (cfg.settings != { } || cfg.context != "" || transformedMcpServers != { })
              )
              [
                ''
                  `programs.opencode` (V1) is enabled, so OpenCode 2 defers the shared
                  {file}`$XDG_CONFIG_HOME/opencode/opencode.json` and {file}`AGENTS.md`
                  to it, and the current `programs.opencode2.settings`/`context`
                  values — and any MCP servers from `programs.mcp.servers` — are not
                  written.

                  Move shared settings into `programs.opencode.settings` in the V1
                  shape — OpenCode 2 normalizes supported V1 fields in memory.
                  V2-only keys have no V1 equivalent; drop them or disable the
                  opencode module.
                ''
              ];
      };
    };
}
