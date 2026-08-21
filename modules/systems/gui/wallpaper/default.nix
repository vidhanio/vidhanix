{ lib, ... }:
{
  flake.aspects.wallpaper = {
    nixos =
      { pkgs, config, ... }:
      let
        colors = config.lib.stylix.colors;
        gradient = {
          black = {
            start = "base00";
            end = "base0D";
            splitPercent = 0.75;
          };
          white = {
            start = "base00";
            end = "base0D";
            splitPercent = 0.50;
          };
        };
        channel =
          endpoint: side: component:
          colors."${endpoint.${side}}-dec-${component}";
        rmsChannel =
          endpoint: component:
          "rms(${channel endpoint "start" component}, ${
            channel endpoint "end" component
          }, ${toString endpoint.splitPercent})";
      in
      {
        stylix = {
          image = pkgs.runCommandLocal "wallpaper.png" { } ''
            gradient=$(
              ${lib.getExe' pkgs.gawk "awk"} '
                function rms(start, end, splitPercent) {
                  return sqrt(splitPercent * start ^ 2 + (1 - splitPercent) * end ^ 2) * 100
                }
                BEGIN {
                  printf "rgb(%.6f%%,%.6f%%,%.6f%%),rgb(%.6f%%,%.6f%%,%.6f%%)",
                    ${rmsChannel gradient.black "r"},
                    ${rmsChannel gradient.black "g"},
                    ${rmsChannel gradient.black "b"},
                    ${rmsChannel gradient.white "r"},
                    ${rmsChannel gradient.white "g"},
                    ${rmsChannel gradient.white "b"}
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
