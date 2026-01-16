{ lib, ... }:
{
  flake.modules = {
    nixos.default =
      { pkgs, config, ... }:
      {
        stylix = {
          image =
            let
              svg = pkgs.replaceVars ./wallpaper.svg (
                with config.lib.stylix.colors.withHashtag;
                {
                  bg = base00;

                  purple = base0E;
                  black = base01;
                  red = base08;

                  ball = base04;

                  claws = base07;
                  teeth = base07;
                  eye = base07;
                }
              );
            in
            pkgs.runCommandLocal "wallpaper.png" { inherit svg; } ''
              ${lib.getExe pkgs.librsvg} $svg -o $out
            '';
        };
      };
    homeManager.default = {
      services.hyprpaper = {
        enable = true;
        settings.splash = false;
      };
    };
  };
}
