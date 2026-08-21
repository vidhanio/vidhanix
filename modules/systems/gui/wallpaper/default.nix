{ lib, ... }:
{
  flake.aspects.wallpaper = {
    nixos =
      { pkgs, config, ... }:
      let
        colors = config.lib.stylix.colors;
        gradient = {
          black = {
            color = "base00";
            start = 0.75;
            end = 0.50;
          };
          accent = {
            color = "base0D";
            start = 0.25;
            end = 0.50;
          };
        };
        channel = color: component: colors."${color}-dec-${component}";
      in
      {
        stylix = {
          image = pkgs.runCommandLocal "wallpaper.png" { } ''
            gradient=$(
              ${lib.getExe' pkgs.gawk "awk"} '
                function rms(a, aWeight, b, bWeight) {
                  return sqrt(aWeight * a ^ 2 + bWeight * b ^ 2) * 100
                }
                BEGIN {
                  blackR = ${channel gradient.black.color "r"}
                  blackG = ${channel gradient.black.color "g"}
                  blackB = ${channel gradient.black.color "b"}
                  accentR = ${channel gradient.accent.color "r"}
                  accentG = ${channel gradient.accent.color "g"}
                  accentB = ${channel gradient.accent.color "b"}
                  printf "rgb(%.6f%%,%.6f%%,%.6f%%),rgb(%.6f%%,%.6f%%,%.6f%%)",
                    rms(blackR, ${toString gradient.black.start}, accentR, ${toString gradient.accent.start}),
                    rms(blackG, ${toString gradient.black.start}, accentG, ${toString gradient.accent.start}),
                    rms(blackB, ${toString gradient.black.start}, accentB, ${toString gradient.accent.start}),
                    rms(blackR, ${toString gradient.black.end}, accentR, ${toString gradient.accent.end}),
                    rms(blackG, ${toString gradient.black.end}, accentG, ${toString gradient.accent.end}),
                    rms(blackB, ${toString gradient.black.end}, accentB, ${toString gradient.accent.end})
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
