{ lib, ... }:
{
  flake.aspects.wallpaper = {
    nixos =
      { pkgs, config, ... }:
      let
        colors = config.lib.stylix.colors;
        toFloat = value: builtins.fromJSON value;
        sqrt = value: lib.foldl' (guess: _: (guess + value / guess) / 2.0) 1.0 (lib.range 1 12);
        rms = a: b: sqrt ((a * a + b * b) / 2.0);
        halfwayChannel =
          channel: rms (toFloat colors."base00-dec-${channel}") (toFloat colors."base0D-dec-${channel}");
        toPercent = value: "${toString (value * 100.0)}%";
        halfway = "rgb(${toPercent (halfwayChannel "r")},${toPercent (halfwayChannel "g")},${toPercent (halfwayChannel "b")})";
      in
      {
        stylix = {
          image = pkgs.runCommandLocal "wallpaper.png" { } ''
            ${lib.getExe' pkgs.imagemagick "magick"} \
              ${./iceman.png} \
              +level-colors "${colors.withHashtag.base00},${halfway}" \
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
