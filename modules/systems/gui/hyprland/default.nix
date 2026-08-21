{
  flake.aspects.hyprland = {
    nixos = {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };
    };
    homeManager =
      { config, ... }:
      {
        # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#nixos-uwsm
        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        wayland.windowManager.hyprland = {
          enable = true;
          # conflicts with UWSM
          systemd.enable = false;
          xdph.settings.screencopy.allow_token_by_default = true;
        };
      };
  };
}
