{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.spotifast;
  json = pkgs.formats.json { };
in
{
  options.programs.spotifast = {
    enable = lib.mkEnableOption "spotifast";

    package = lib.mkPackageOption pkgs "spotifast" {
      nullable = true;
      default = null;
    };

    settings = lib.mkOption {
      inherit (json) type;
      default = { };
      description = "Configuration written to {file}`~/.config/spotifast/settings.json`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."spotifast/settings.json" = lib.mkIf (cfg.settings != { }) {
      source = json.generate "spotifast-settings.json" cfg.settings;
    };
  };
}
