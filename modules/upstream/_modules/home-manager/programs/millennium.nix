{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.millennium;
  json = pkgs.formats.json { };
  configPath = "${config.xdg.configHome}/millennium/config.json";
in
{
  meta.maintainers = [ lib.hm.maintainers.vidhanio ];

  options.programs.millennium = {
    enable = lib.mkEnableOption "Millennium configuration for Steam";

    themes = lib.mkOption {
      type = lib.types.addCheck (lib.types.attrsOf lib.types.path) (
        themes:
        lib.all (name: name != "" && name != "." && name != ".." && !lib.hasInfix "/" name) (
          builtins.attrNames themes
        )
      );
      default = { };
      description = ''
        Theme trees containing a {file}`skin.json` manifest. Each key is the
        theme's directory name under {file}`$XDG_DATA_HOME/Steam/millennium/themes`
        and the name Millennium uses to identify it in its settings.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf json.type;
      default = { };
      description = ''
        JSON settings recursively merged into Millennium's writable
        {file}`$XDG_CONFIG_HOME/millennium/config.json` at activation.
        Settings not specified here remain under Millennium's control.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.dataFile = lib.mapAttrs' (
      name: source: lib.nameValuePair "Steam/millennium/themes/${name}" { inherit source; }
    ) cfg.themes;

    home.activation.millenniumSettings = lib.mkIf (cfg.settings != { }) (
      lib.hm.dag.entryAfter [ "linkGeneration" ] (
        let
          path = lib.escapeShellArg configPath;
        in
        # The merger normally treats an empty file as missing; for JSON an
        # existing empty file is invalid and must not be overwritten.
        ''
          if [[ ! -v DRY_RUN && -e ${path} && ( ! -f ${path} || ! -s ${path} ) ]]; then
            errorEcho ${lib.escapeShellArg "Expected a nonempty JSON file at '${configPath}'; refusing to merge."}
            exit 1
          fi
        ''
        + lib.hm.generators.mkImpureConfigMerger {
          inherit pkgs;
          format = "json";
          empty = "{}";
          jqOperation = ''
            if ($dynamic | type) == "object" then $dynamic * $static
            else error("expected a JSON object") end
          '';
          path = configPath;
          staticSettings = json.generate "millennium-settings.json" cfg.settings;
          mode = "600";
        }
      )
    );
  };
}
