{
  flake.modules = {
    nixos.default = {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };
    };
    homeManager.default =
      { config, ... }:
      {
        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        home.pointerCursor.hyprcursor.enable = true;

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
        };
      };
  };
}
