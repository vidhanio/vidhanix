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
            halfway=$(
              ${lib.getExe' pkgs.gawk "awk"} 'BEGIN {
                printf "rgb(%.6f%%,%.6f%%,%.6f%%)",
                  sqrt((${colors."base00-dec-r"} ^ 2 + ${colors."base0D-dec-r"} ^ 2) / 2) * 100,
                  sqrt((${colors."base00-dec-g"} ^ 2 + ${colors."base0D-dec-g"} ^ 2) / 2) * 100,
                  sqrt((${colors."base00-dec-b"} ^ 2 + ${colors."base0D-dec-b"} ^ 2) / 2) * 100
              }'
            )

            ${lib.getExe' pkgs.imagemagick "magick"} \
              ${./iceman.png} \
              +level-colors "${colors.withHashtag.base00},$halfway" \
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
