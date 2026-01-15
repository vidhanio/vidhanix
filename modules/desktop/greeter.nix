{ lib, ... }:
{
  flake.modules = {
    nixos.default =
      { pkgs, ... }:
      {
        programs.regreet = {
          enable = true;
          # "https://github.com/NixOS/nixpkgs/pull/478883"
          cageArgs = [
            "-s"
            "-d"
          ];
        };

        services.greetd.settings.initial_session = {
          command = "${lib.getExe pkgs.uwsm} start -e -D Hyprland ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop";
          user = "vidhanio";
        };
      };
  };

  configurations = {
    vidhan-pc.module =
      { pkgs, ... }:
      {
        programs.regreet.package = pkgs.writeShellApplication {
          name = "regreet-only-main-display";
          derivationArgs = { inherit (pkgs.regreet) version; };
          runtimeInputs = with pkgs; [
            wlr-randr
            regreet
          ];
          text = ''
            wlr-randr --output DP-1 --mode 2560x1440@300.002014Hz --adaptive-sync enabled
            wlr-randr --output HDMI-A-1 --off
            regreet "$@"
          '';
        };
      };
    vidhan-macbook.module =
      { pkgs, ... }:
      {
        programs.regreet.package = pkgs.writeShellApplication {
          name = "regreet-scaling";
          derivationArgs = { inherit (pkgs.regreet) version; };
          runtimeInputs = with pkgs; [
            wlr-randr
            regreet
          ];
          text = ''
            wlr-randr --output eDP-1 --scale 1.6
            regreet "$@"
          '';
        };
      };
  };
}
