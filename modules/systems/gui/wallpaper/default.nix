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
                ${./iceman.png} \
                +level-colors "${base00},${base02}" \
                -colorspace sRGB \
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
