{ lib, ... }:
{
  flake.modules = {
    nixos.default =
      { pkgs, config, ... }:
      {
        stylix = {
          image =
            with config.lib.stylix.colors.withHashtag;
            pkgs.runCommandLocal "wallpaper.png" { } ''
              ${lib.getExe' pkgs.imagemagick "magick"} \
                ${./nokia.png} \
                -colorspace sRGB \
                -fuzz 50% -fill "${base01}" -opaque black \
                -fuzz 50% -fill "${base07}" -opaque white \
                $out
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
