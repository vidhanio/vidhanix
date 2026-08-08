{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.hermes;
      yamlFormat = pkgs.formats.yaml { };

      resourceAssertion =
        { dir, resources }:
        {
          assertion = !lib.hm.strings.isPathLike resources || lib.pathIsDirectory resources;
          message = "`programs.hermes.${dir}` must be a directory when set to a path";
        };
    in
    {
      options.programs.hermes = {
        enable = lib.mkEnableOption "Hermes Agent";

        package = lib.mkPackageOption pkgs "hermes-agent" { nullable = true; };

        settings = lib.mkOption {
          inherit (yamlFormat) type;
          default = { };
          example = {
            model = "opencode-go/deepseek-v4-flash";
            agent = {
              reasoning_effort = "max";
            };
            display = {
              skin = "stylix";
            };
          };
          description = ''
            Configuration written to {file}`~/.hermes/config.yaml`.
            See
            <https://github.com/NousResearch/hermes-agent/blob/v2026.8.3/website/docs/user-guide/configuration.md>
            for the documentation.

            Settings are nested YAML keys that are deeply merged over the
            built-in defaults. Model strings use the `provider/model` form
            (e.g. `opencode-go/deepseek-v4-flash`). `display.skin` selects
            the active skin: a built-in (`default`, `mono`, ...) or a custom
            skin written by {option}`programs.hermes.skins`.
          '';
        };

        skins = lib.mkOption {
          type = lib.types.either (lib.types.attrsOf (lib.types.either yamlFormat.type lib.types.path)) lib.types.path;
          default = { };
          example = {
            stylix = {
              name = "stylix";
              description = "Stylix base16 palette";
              colors.background = "#151515";
              colors.ui_accent = "#00aaff";
            };
          };
          description = ''
            Custom skins for Hermes Agent, written to
            {file}`~/.hermes/skins/`.

            This option can either be:
            - An attribute set defining skins
            - A path to a directory containing skin files

            If an attribute set is used, the attribute name becomes the skin
            filename (and therefore the skin name), and the value is either:
            - An attribute set that is converted to a YAML file
            - A path to a file

            If a path is used, it is expected to contain skin files. The
            directory is symlinked to {file}`~/.hermes/skins/`.

            A `name` key is added automatically to generated skin files;
            values given here take precedence. Missing color keys inherit
            from the built-in `default` skin. See
            <https://github.com/NousResearch/hermes-agent/blob/v2026.8.3/website/docs/user-guide/features/skins.md>
            for the skin schema.

            Set {option}`programs.hermes.settings.display.skin` to enable a
            skin.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

        home.file = {
          ".hermes/config.yaml" = lib.mkIf (cfg.settings != { }) {
            source = yamlFormat.generate "hermes-config.yaml" cfg.settings;
          };
        }
        // (lib.optionalAttrs (lib.hm.strings.isPathLike cfg.skins) {
          ".hermes/skins" = {
            source = cfg.skins;
            recursive = true;
          };
        })
        // lib.mapAttrs' (
          name: content:
          lib.nameValuePair ".hermes/skins/${name}.yaml" (
            if lib.isPath content then
              { source = content; }
            else
              {
                source = yamlFormat.generate "hermes-${name}.yaml" (
                  {
                    inherit name;
                  }
                  // content
                );
              }
          )
        ) (if lib.isAttrs cfg.skins then cfg.skins else { });

        assertions = map resourceAssertion [
          {
            dir = "skins";
            resources = cfg.skins;
          }
        ];
      };
    };
}
