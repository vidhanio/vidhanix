{
  profiles.pc = {
    module =
      { inputs', ... }:
      {
        programs.hyprland = {
          enable = true;

          package = inputs'.hyprland.packages.hyprland;
          portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;

          withUWSM = true;
        };
      };
    homeModule =
      { config, inputs', ... }:
      {
        # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#nixos-uwsm
        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        wayland.windowManager.hyprland = {
          enable = true;

          package = inputs'.hyprland.packages.hyprland;
          portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;

          # Conflicts with `uwsm`.
          systemd.enable = false;

          xdph.settings.screencopy.allow_token_by_default = true;
          settings.config = {
            ecosystem = {
              no_update_news = true;
              no_donation_nag = true;
            };
            misc.disable_splash_rendering = true;
            xwayland.force_zero_scaling = true;
          };
        };
      };
  };
}
