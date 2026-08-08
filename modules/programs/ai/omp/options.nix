{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.omp;
      yamlFormat = pkgs.formats.yaml { };
      jsonFormat = pkgs.formats.json { };

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

            If an attribute set is used, the attribute name becomes the
            resource name, and the value is either:
            - Inline content as a string
            - A path to a file
            - A path to a directory

            If a path is used, it is expected to contain one folder per
            resource name. The directory is symlinked to
            {file}`~/.omp/agent/${dir}/`.
          '';
        };

      resourceFiles =
        dir: suffix: resources:
        let
          attrs = if lib.isAttrs resources then resources else { };
        in
        (lib.optionalAttrs (lib.hm.strings.isPathLike resources) {
          ".omp/agent/${dir}" = {
            source = resources;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          if lib.hm.strings.isPathLike content && lib.pathIsDirectory content then
            lib.nameValuePair ".omp/agent/${dir}/${name}" {
              source = content;
              recursive = true;
            }
          else
            lib.nameValuePair ".omp/agent/${dir}/${name}${suffix}" (
              if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
            )
        ) attrs;

      resourceAssertion =
        { dir, resources }:
        {
          assertion = !lib.hm.strings.isPathLike resources || lib.pathIsDirectory resources;
          message = "`programs.omp.${dir}` must be a directory when set to a path";
        };
    in
    {
      options.programs.omp = {
        enable = lib.mkEnableOption "Oh My Pi";

        package = lib.mkPackageOption pkgs "omp" { nullable = true; };

        settings = lib.mkOption {
          inherit (yamlFormat) type;
          default = { };
          example = {
            theme.dark = "titanium";
            symbolPreset = "nerd";
            modelRoles.default = "anthropic/claude-sonnet-4-5";
            tools.approvalMode = "write";
            memory.backend = "off";
          };
          description = ''
            Configuration written to {file}`~/.omp/agent/config.yml`.
            See <https://omp.sh/docs/settings> for the documentation.

            Settings are namespaced dotted keys (`theme.dark`,
            `tools.approvalMode`, `memory.backend`, ...); each becomes a
            nested mapping in the YAML file. The binary is Nix-managed, so
            consider setting `startup.checkUpdate = false`.
          '';
        };

        keybindings = lib.mkOption {
          inherit (yamlFormat) type;
          default = { };
          example = {
            "app.model.cycleForward" = "Ctrl+P";
            "app.history.search" = [ ];
          };
          description = ''
            Keybinding remaps written to {file}`~/.omp/agent/keybindings.yml`.

            Keys are keybinding action IDs; values are either one chord string
            or an array of chord strings. An empty array disables the action.
            See <https://omp.sh/docs/keybindings> for the documentation and
            the action ID reference.
          '';
        };

        context = lib.mkOption {
          type = lib.types.either lib.types.lines lib.types.path;
          default = "";
          description = ''
            Global context for Oh My Pi, written to
            {file}`~/.omp/agent/AGENTS.md`.

            The value is either:
            - Inline content as a string
            - A path to a file containing the content
          '';
          example = "Prefer the project-local AGENTS.md; escalate to the user before editing system files.";
        };

        themes = lib.mkOption {
          type = lib.types.either (lib.types.attrsOf (lib.types.either jsonFormat.type lib.types.path)) lib.types.path;
          default = { };
          example = {
            stylix = {
              name = "stylix";
              colors.accent = "#00aaff";
            };
          };
          description = ''
            Custom themes for Oh My Pi, written to
            {file}`~/.omp/agent/themes/`.

            This option can either be:
            - An attribute set defining themes
            - A path to a directory containing theme files

            If an attribute set is used, the attribute name becomes the theme
            filename (and therefore the theme name), and the value is either:
            - An attribute set that is converted to a JSON file
            - A path to a file

            If a path is used, it is expected to contain theme files. The
            directory is symlinked to {file}`~/.omp/agent/themes/`.

            A `$schema` key and the theme `name` are added automatically to
            generated theme files; values given here take precedence. The
            theme JSON must provide every key of `colors` (see
            <https://omp.sh/docs/themes> for the token reference); the
            built-in themes under
            <https://github.com/can1357/oh-my-pi/tree/main/packages/coding-agent/src/modes/theme>
            are good starting points.

            Set {option}`programs.omp.settings.theme.dark` (or
            {option}`programs.omp.settings.theme.light`) to enable a theme.
          '';
        };

        commands = mkResourceOption {
          dir = "commands";
          description = ''
            Custom slash commands for Oh My Pi, written to
            {file}`~/.omp/agent/commands/`.

            The Markdown body is the command template. See
            <https://omp.sh/docs/slash> for the documentation.
          '';
        };

        skills = mkResourceOption {
          dir = "skills";
          description = ''
            Custom skills for Oh My Pi, written to
            {file}`~/.omp/agent/skills/`.

            The directory name becomes the skill ID; each skill may carry
            supporting scripts and references next to its {file}`SKILL.md`.
            See <https://omp.sh/docs/skills> for the documentation.
          '';
        };

        prompts = mkResourceOption {
          dir = "prompts";
          description = ''
            Custom prompt templates for Oh My Pi, written to
            {file}`~/.omp/agent/prompts/`.

            See <https://omp.sh/docs/prompt-templates> for the documentation.
          '';
        };

        tools = mkResourceOption {
          dir = "tools";
          description = ''
            Custom tools for Oh My Pi, written to
            {file}`~/.omp/agent/tools/`.

            See <https://omp.sh/docs/custom-tools> for the documentation.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

        home.file = {
          ".omp/agent/config.yml" = lib.mkIf (cfg.settings != { }) {
            source = yamlFormat.generate "omp-config.yml" cfg.settings;
          };

          ".omp/agent/keybindings.yml" = lib.mkIf (cfg.keybindings != { }) {
            source = yamlFormat.generate "omp-keybindings.yml" cfg.keybindings;
          };

          ".omp/agent/AGENTS.md" =
            if lib.isPath cfg.context then
              { source = cfg.context; }
            else
              lib.mkIf (cfg.context != "") {
                text = cfg.context;
              };
        }
        // (lib.optionalAttrs (lib.hm.strings.isPathLike cfg.themes) {
          ".omp/agent/themes" = {
            source = cfg.themes;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          lib.nameValuePair ".omp/agent/themes/${name}.json" (
            if lib.isPath content then
              { source = content; }
            else
              {
                source = jsonFormat.generate "omp-${name}.json" (
                  {
                    "$schema" =
                      "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/theme-schema.json";
                    inherit name;
                  }
                  // content
                );
              }
          )
        ) (if lib.isAttrs cfg.themes then cfg.themes else { })
        // resourceFiles "commands" ".md" cfg.commands
        // resourceFiles "skills" "/SKILL.md" cfg.skills
        // resourceFiles "prompts" ".md" cfg.prompts
        // resourceFiles "tools" ".ts" cfg.tools;

        assertions = map resourceAssertion [
          {
            dir = "commands";
            resources = cfg.commands;
          }
          {
            dir = "skills";
            resources = cfg.skills;
          }
          {
            dir = "prompts";
            resources = cfg.prompts;
          }
          {
            dir = "tools";
            resources = cfg.tools;
          }
          {
            dir = "themes";
            resources = cfg.themes;
          }
        ];
      };
    };
}
