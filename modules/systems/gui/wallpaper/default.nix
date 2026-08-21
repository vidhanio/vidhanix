{ lib, ... }:
{
  flake.aspects.wallpaper = {
    nixos =
      { pkgs, config, ... }:
      let
        colors = config.lib.stylix.colors;
      in
      {
        stylix = {
          image = pkgs.runCommandLocal "wallpaper.png" { } ''
            gradient=$(
              ${lib.getExe' pkgs.gawk "awk"} '
                function rms(a, b, weight) {
                  return sqrt((1 - weight) * a ^ 2 + weight * b ^ 2) * 100
                }
                BEGIN {
                  r0 = ${colors.base00-dec-r}; g0 = ${colors.base00-dec-g}; b0 = ${colors.base00-dec-b}
                  rD = ${colors.base0D-dec-r}; gD = ${colors.base0D-dec-g}; bD = ${colors.base0D-dec-b}
                  printf "rgb(%.6f%%,%.6f%%,%.6f%%),rgb(%.6f%%,%.6f%%,%.6f%%)",
                    rms(r0, rD, 0.25), rms(g0, gD, 0.25), rms(b0, bD, 0.25),
                    rms(r0, rD, 0.50), rms(g0, gD, 0.50), rms(b0, bD, 0.50)
                }
              '
            )

            ${lib.getExe' pkgs.imagemagick "magick"} \
              ${./iceman.png} \
              +level-colors "$gradient" \
              -colorspace sRGB \
              $out
          '';
        };
      };

    homeManager = {
      services.hyprpaper = {
        enable = true;
        settings.splash = false;
      };
    };
  };
}
