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
        # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#nixos-uwsm
        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        # make screenshare dialog not pop up multiple times
        xdg.configFile."hypr/xdph.conf".text = ''
          screencopy {
            allow_token_by_default = true
          }
        '';

        wayland.windowManager.hyprland = {
          enable = true;
          # conflicts with UWSM
          systemd.enable = false;
        };
      };
  };
}
