{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.vacuum-tube;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.vacuum-tube = {
    enable = lib.mkEnableOption "VacuumTube";
    config = lib.mkOption {
      type = jsonFormat.type;
      default = {
        fullscreen = false;
        adblock = true;
        dearrow = false;
        dislikes = true;
        hide_shorts = false;
        h264ify = false;
        hardware_decoding = true;
        low_memory_mode = false;
        keep_on_top = false;
        userstyles = false;
      };
      description = "VaccumTube config written to {file}`$XDG_CONFIG_HOME/VacuumTube/config.json`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.vacuum-tube ];

    xdg.configFile."VacuumTube/config.json" = lib.mkIf (cfg.config != { }) {
      source = jsonFormat.generate "vacuumtube-config" cfg.config;
    };

    impermanence.directories = [ ".config/VacuumTube/sessionData" ];
  };
}
