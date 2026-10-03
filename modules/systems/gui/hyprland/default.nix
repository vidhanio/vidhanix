{
  flake-file = {
    inputs.hyprland = {
      url = "github:hyprwm/Hyprland";
      # follow upstream's nixpkgs so the cachix cache is not invalidated
      inputs.nixpkgs.autoFollow = false;
    };

    nixConfig = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  flake.aspects.hyprland = {
    nixos =
      { inputs', ... }:
      {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
          package = inputs'.hyprland.packages.hyprland;
          portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
        };
      };
    homeManager =
      { config, inputs', ... }:
      {
        # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#nixos-uwsm
        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        wayland.windowManager.hyprland = {
          enable = true;
          package = inputs'.hyprland.packages.hyprland;
          portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
          # conflicts with UWSM
          systemd.enable = false;
          xdph.settings.screencopy.allow_token_by_default = true;
        };
      };
  };
}
