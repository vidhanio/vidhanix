{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.bb;
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
            symlinked to {file}`~/.bb/${dir}/`.
          '';
        };

      resourceFiles =
        dir: suffix: resources:
        let
          attrs = if lib.isAttrs resources then resources else { };
        in
        (lib.optionalAttrs (lib.hm.strings.isPathLike resources) {
          ".bb/${dir}" = {
            source = resources;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          if lib.hm.strings.isPathLike content && lib.pathIsDirectory content then
            lib.nameValuePair ".bb/${dir}/${name}" {
              source = content;
              recursive = true;
            }
          else
            lib.nameValuePair ".bb/${dir}/${name}${suffix}" (
              if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
            )
        ) attrs;

      resourceAssertion =
        { dir, resources }:
        {
          assertion = !lib.hm.strings.isPathLike resources || lib.pathIsDirectory resources;
          message = "`programs.bb.${dir}` must be a directory when set to a path";
        };

      managedConfigExample = {
        config = {
          BB_INFERENCE = "acp-opencode/deepseek-v4-flash";
          BB_INFERENCE_FALLBACK = "acp-opencode/deepseek-v4-flash";
          BB_LOG_LEVEL = "info";
        };
        customModels = [
          {
            providerId = "pi";
            model = "claude-sonnet-4-5";
          }
        ];
      };
    in
    {
      options.programs.bb = {
        enable = lib.mkEnableOption "bb";

        package = lib.mkPackageOption pkgs "bb-app" { nullable = true; };

        settings = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          example = managedConfigExample;
          description = ''
            Configuration written to {file}`~/.bb/config.json`.

            A `config` key holds the flat package settings (`BB_APP_URL`,
            `BB_INFERENCE`, `BB_INFERENCE_FALLBACK`, `BB_LOG_LEVEL`,
            `BB_TRANSCRIPTION`), plus optional `customAcpAgents`,
            `customModels`, and `sharedSkillRoots` lists. Unknown top-level
            keys are rejected, so prefer the declarative sub-options of this
            module for content bb has a dedicated option for.

            See
            <https://github.com/get-bb/bb/blob/main/docs/configuration.md>
            for the documentation.
          '';
        };

        env = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          example = {
            env.OPENAI_API_KEY = "sk-...";
          };
          description = ''
            Provider environment written to {file}`~/.bb/env.json`, for
            example provider credentials or provider-specific environment.

            Prefer {option}`sops.templates` for secret values; the file is
            world-readable like any dotfile. See
            <https://github.com/get-bb/bb/blob/main/docs/configuration.md>
            for the documentation.
          '';
        };

        client = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          example = {
            servers."https://bb.example.test".hosts.host_abc = {
              sshAuthority = "devbox";
            };
          };
          description = ''
            Client SSH target mappings written to {file}`~/.bb/client.json`,
            used by the local helper to open files from a remote bb server in
            local editors. See
            <https://github.com/get-bb/bb/blob/main/docs/configuration.md>
            for the documentation.
          '';
        };

        context = lib.mkOption {
          type = lib.types.either lib.types.lines lib.types.path;
          default = "";
          description = ''
            Global context for bb.

            The value is either:
            - Inline content as a string
            - A path to a file containing the content

            The configured content is written to {file}`~/.bb/AGENTS.md`, and
            appended to the system prompt of every provider-backed thread.
          '';
          example = "Prefer the /status command when asked for a summary of work.";
        };

        skills = mkResourceOption {
          dir = "skills";
          description = ''
            Custom skills for bb.

            This option can be either:
            - An attribute set defining skills
            - A path to a directory containing skill folders

            If an attribute set is used, the attribute name becomes the
            skill directory name, and the value is either:
            - Inline content as a string (creates `~/.bb/skills/<name>/SKILL.md`)
            - A path to a file (creates `~/.bb/skills/<name>/SKILL.md`)
            - A path to a directory (creates `~/.bb/skills/<name>/` with all files)

            This also accepts Nix store paths, for example a skill directory from
            a package.

            If a path is used, it is expected to contain one folder per skill name,
            each containing a {file}`SKILL.md`. The directory is symlinked to
            {file}`~/.bb/skills/`.
          '';
        };

        themes = lib.mkOption {
          type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
          default = { };
          example = {
            stylix = ''
              :root, .light {
                --canvas: #f5f5f5;
                --ink: #2e3440;
                --primary: #5e81ac;
              }
            '';
          };
          description = ''
            Custom themes for bb.

            This option can either be:
            - An attribute set defining themes
            - A path to a directory containing theme folders

            If an attribute set is used, the attribute name becomes the theme
            directory name, and the value is:
            - Inline CSS as a string (creates `~/.bb/theme/<name>/theme.css`)
            - A path to a CSS file (creates `~/.bb/theme/<name>/theme.css`)

            If a path is used, it is expected to contain one folder per theme
            name, each containing a {file}`theme.css`. The directory is
            symlinked to {file}`~/.bb/theme/`.

            The CSS overrides the app's CSS custom properties (`--canvas`,
            `--ink`, `--primary`, ...); every neutral surface derives from the
            anchors and accent. Set the active theme once with
            `bb theme set <name>` or in Settings → Appearance (the selection is
            persisted server-side, so it cannot be declarative).
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

        home.file = {
          ".bb/config.json" = lib.mkIf (cfg.settings != { }) {
            source = jsonFormat.generate "bb-config.json" cfg.settings;
          };

          ".bb/env.json" = lib.mkIf (cfg.env != { }) {
            source = jsonFormat.generate "bb-env.json" cfg.env;
          };

          ".bb/client.json" = lib.mkIf (cfg.client != { }) {
            source = jsonFormat.generate "bb-client.json" cfg.client;
          };

          ".bb/AGENTS.md" =
            if lib.isPath cfg.context then
              { source = cfg.context; }
            else
              lib.mkIf (cfg.context != "") {
                text = cfg.context;
              };
        }
        // (lib.optionalAttrs (lib.hm.strings.isPathLike cfg.themes) {
          ".bb/theme" = {
            source = cfg.themes;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          lib.nameValuePair ".bb/theme/${name}/theme.css" (
            if lib.isPath content then { source = content; } else { text = content; }
          )
        ) (if lib.isAttrs cfg.themes then cfg.themes else { })
        // resourceFiles "skills" "/SKILL.md" cfg.skills;

        assertions = map resourceAssertion [
          {
            dir = "skills";
            resources = cfg.skills;
          }
          {
            dir = "theme";
            resources = cfg.themes;
          }
        ];
      };
    };
}
