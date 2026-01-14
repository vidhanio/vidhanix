{
  withSystem,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    stylix.url = "github:nix-community/stylix";
  };

  flake.modules.nixos.default =
    { pkgs, config, ... }:
    {
      imports = [ inputs.stylix.nixosModules.default ];

      stylix = {
        enable = true;
        polarity = "dark";
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
        base16Scheme = ./scheme.yaml;
        cursor = {
          package = withSystem pkgs.stdenv.hostPlatform.system (
            { inputs', ... }: inputs'.rose-pine-hyprcursor.packages.default
          );
          name = "rose-pine-hyprcursor";
          size = 24;
        };
      };
    };
}
