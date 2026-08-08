{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.prime-agent;
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

            If an attribute set is used, the attribute name becomes the resource
            name, and the value is either:
            - Inline content as a string
            - A path to a file
            - A path to a directory

            If a path is used, it is expected to contain one folder per resource
            name. The directory is symlinked to
            {file}`~/.prime/agent/${dir}/`.
          '';
        };

      # Symlink each resource into `~/.prime/agent/<dir>/<name><suffix>`.
      resourceFiles =
        dir: suffix: resources:
        let
          attrs = if lib.isAttrs resources then resources else { };
        in
        (lib.optionalAttrs (lib.hm.strings.isPathLike resources) {
          ".prime/agent/${dir}" = {
            source = resources;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          if lib.hm.strings.isPathLike content && lib.pathIsDirectory content then
            lib.nameValuePair ".prime/agent/${dir}/${name}" {
              source = content;
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
          assertion = !lib.hm.strings.isPathLike resources || lib.pathIsDirectory resources;
          message = "`programs.prime-agent.${dir}` must be a directory when set to a path";
        };
    in
    {
      options.programs.prime-agent = {
        enable = lib.mkEnableOption "Prime Agent";

        package = lib.mkPackageOption pkgs "prime-agent" { nullable = true; };

        settings = lib.mkOption {
          inherit (jsonFormat) type;
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
            Custom skills for Prime Agent, written to
            {file}`~/.prime/agent/skills/`.
          '';
        };

        extensions = mkResourceOption {
          dir = "extensions";
          description = ''
            Custom TypeScript extensions for Prime Agent, written to
            {file}`~/.prime/agent/extensions/`.
          '';
        };

        prompts = mkResourceOption {
          dir = "prompts";
          description = ''
            Custom prompt templates for Prime Agent, written to
            {file}`~/.prime/agent/prompts/`.
          '';
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
                Custom themes for Prime Agent, written to
                {file}`~/.prime/agent/themes/`.

                This option can either be:
                - An attribute set defining themes
                - A path to a directory containing theme files

                If an attribute set is used, the attribute name becomes the theme
                filename, and the value is either:
                - An attribute set that is converted to a JSON file
                - A path to a file

            If a path is used, it is expected to contain theme files. The
            directory is symlinked to {file}`~/.prime/agent/themes/`.

            A `$schema` key and the theme `name` are added automatically to
            generated theme files; values given here take precedence.

            Set {option}`programs.prime-agent.settings.theme` to enable a theme.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

        home.file = {
          ".prime/agent/settings.json" = lib.mkIf (cfg.settings != { }) {
            source = jsonFormat.generate "prime-agent-settings.json" cfg.settings;
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
                source = jsonFormat.generate "prime-agent-${name}.json" (
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
}
