{
  flake-file = {
    inputs.hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.autoFollow = false;
    };

    nixConfig = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

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

          # conflicts with uwsm
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
