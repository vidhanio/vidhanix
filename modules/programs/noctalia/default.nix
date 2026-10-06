{
  profiles.pc = {
    module = {
      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };

    homeModule = {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
        settings = {
          lockscreen.enabled = false; # handled by hyprlock
          location.auto_locate = true;
          control_center.sidebar_section = "none";
          dock.enabled = false;
        };
      };

      persist.directories = [ ".local/state/noctalia" ];
      systemd.user.tmpfiles.rules = [
        "r %h/.local/state/noctalia/settings.toml" # get rid of imperative settings
      ];
    };
  };
}
