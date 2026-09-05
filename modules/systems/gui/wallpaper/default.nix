{ lib, ... }:
{
  flake.aspects.wallpaper = {
    nixos =
      { pkgs, config, ... }:
      let
        colors = config.lib.stylix.colors;
        gradient = {
          black = "base00";
          white = "base0D";
          blackSplit = 0;
          whiteSplit = 0.2;
        };
        channel = color: component: colors."${color}-dec-${component}";
        rmsChannel =
          split: component:
          "rms(${channel gradient.black component}, ${channel gradient.white component}, ${toString split})";
      in
      {
        stylix = {
          image = pkgs.runCommandLocal "wallpaper.png" { } ''
            gradient=$(
              ${lib.getExe' pkgs.gawk "awk"} '
                function rms(start, end, splitPercent) {
                  return sqrt((1 - splitPercent) * start ^ 2 + splitPercent * end ^ 2) * 100
                }
                BEGIN {
                  printf "rgb(%.6f%%,%.6f%%,%.6f%%),rgb(%.6f%%,%.6f%%,%.6f%%)",
                    ${rmsChannel gradient.blackSplit "r"},
                    ${rmsChannel gradient.blackSplit "g"},
                    ${rmsChannel gradient.blackSplit "b"},
                    ${rmsChannel gradient.whiteSplit "r"},
                    ${rmsChannel gradient.whiteSplit "g"},
                    ${rmsChannel gradient.whiteSplit "b"}
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
