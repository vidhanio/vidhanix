{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.vacuumtube;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.vacuumtube = {
    enable = lib.mkEnableOption "VacuumTube";
    config = lib.mkOption {
      type = jsonFormat.type;
      default = { };
      description = "VaccumTube config written to {file}`$XDG_CONFIG_HOME/VacuumTube/config.json`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.vacuumtube-bin ];

    xdg.configFile."VacuumTube/config.json" = lib.mkIf (cfg.config != { }) {
      source = jsonFormat.generate "vacuumtube-config" cfg.config;
    };

    impermanence.directories = [ ".config/VacuumTube/sessionData" ];
  };
}
