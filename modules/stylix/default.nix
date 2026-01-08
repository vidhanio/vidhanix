{ inputs, ... }:
{
  flake-file.inputs.stylix.url = "github:nix-community/stylix";

  flake.modules.nixos.default =
    { pkgs, config, ... }:
    {
      imports = [ inputs.stylix.nixosModules.default ];

      stylix = {
        enable = true;
        polarity = "dark";
        image =
          with config.lib.stylix.colors.withHashtag;
          pkgs.replaceVars ./wallpaper.svg {
            bg = base00;

            purple = base0E;
            black = base01;
            red = base08;

            ball = base04;

            claws = base07;
            teeth = base07;
            eye = base07;
          };
        base16Scheme = ./scheme.yaml;
      };
    };
}
