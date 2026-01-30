{ inputs, ... }:
{
  flake-file = {
    inputs.hyprland.url = "github:hyprwm/Hyprland";

    nixConfig = {
      extra-substituters = [ "https://hyprland.cachix.org" ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  flake.modules = {
    nixos.default = {
      imports = [ inputs.hyprland.nixosModules.default ];

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };
    };
    homeManager.default =
      { config, ... }:
      {
        imports = [ inputs.hyprland.homeManagerModules.default ];

        xdg.configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false;
        };
      };
  };
}
