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

            Either an attribute set of resources or a path to a directory,
            symlinked to {file}`~/.omp/agent/${dir}/`.
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
            See <https://omp.sh/docs/keybindings> for the documentation.
          '';
        };

        context = lib.mkOption {
          type = lib.types.either lib.types.lines lib.types.path;
          default = "";
          description = ''
            Global context for Oh My Pi.

            The value is either:
            - Inline content as a string
            - A path to a file containing the content

            The configured content is written to {file}`~/.omp/agent/AGENTS.md`.
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
            Custom themes for Oh My Pi.

            This option can either be:
            - An attribute set defining themes
            - A path to a directory containing multiple theme files

            If an attribute set is used, the attribute name becomes the theme filename,
            and the value is either:
            - An attribute set that is converted to a JSON file
            - A path to a file

            If a path is used, it is expected to contain theme files.
            The directory is symlinked to {file}`~/.omp/agent/themes/`.

            A `$schema` key and the theme `name` are added automatically.

            Set {option}`programs.omp.settings.theme.dark` to enable a theme.
          '';
        };

        commands = mkResourceOption {
          dir = "commands";
          description = ''
            Custom command for Oh My Pi.

            This option can either be:
            - An attribute set defining commands
            - A path to a directory containing multiple commands files

            If an attribute set is used, the attribute name becomes the command filename,
            and the value is either:
            - Inline content as a string (creates `opencode/commands/<name>.md`)
            - A path to a file (creates `opencode/commands/<name>.md`)

            If a path is used, it is expected to contain commands files.
            The directory is symlinked to {file}`~/.omp/agent/commands/`.
          '';
        };

        skills = mkResourceOption {
          dir = "skills";
          description = ''
            Custom skills for Oh My Pi.

            This option can be either:
            - An attribute set defining skills
            - A path to a directory containing skill folders

            If an attribute set is used, the attribute name becomes the
            skill directory name, and the value is either:
            - Inline content as a string (creates `~/.omp/agent/skills/<name>/SKILL.md`)
            - A path to a file (creates `~/.omp/agent/skills/<name>/SKILL.md`)
            - A path to a directory (creates `~/.omp/agent/skills/<name>/` with all files)

            This also accepts Nix store paths, for example a skill directory from
            a package.

            If a path is used, it is expected to contain one folder per skill name,
            each containing a {file}`SKILL.md`. The directory is symlinked to
            {file}`~/.omp/agent/skills/`.
          '';
        };

        prompts = mkResourceOption {
          dir = "prompts";
          description = ''
            Custom prompt template for Oh My Pi.

            This option can either be:
            - An attribute set defining prompt templates
            - A path to a directory containing multiple prompt templates files

            If an attribute set is used, the attribute name becomes the prompt template filename,
            and the value is either:
            - Inline content as a string (creates `opencode/prompts/<name>.md`)
            - A path to a file (creates `opencode/prompts/<name>.md`)

            If a path is used, it is expected to contain prompt templates files.
            The directory is symlinked to {file}`~/.omp/agent/prompts/`.
          '';
        };

        tools = mkResourceOption {
          dir = "tools";
          description = ''
            Custom tool for Oh My Pi.

            This option can either be:
            - An attribute set defining tools
            - A path to a directory containing multiple tools files

            If an attribute set is used, the attribute name becomes the tool filename,
            and the value is either:
            - Inline content as a string (creates `opencode/tools/<name>.ts`)
            - A path to a file (creates `opencode/tools/<name>.ts`)

            If a path is used, it is expected to contain tools files.
            The directory is symlinked to {file}`~/.omp/agent/tools/`.
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
