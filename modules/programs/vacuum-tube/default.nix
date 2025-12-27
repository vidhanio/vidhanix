{
  flake.modules.homeManager.default = {
    programs.vacuum-tube = {
      enable = true;
      settings = {
        fullscreen = true;
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
    };

    persist.directories = [ ".config/VacuumTube/sessionData/Local Storage" ];
  };
}
