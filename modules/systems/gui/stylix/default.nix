{ inputs, lib, ... }:
let
  schemes = {
    dark = "${inputs.tinted-schemes}/base16/catppuccin-mocha.yaml";
    light = "${inputs.tinted-schemes}/base16/catppuccin-latte.yaml";
  };
in
{
  flake-file.inputs = {
    stylix.url = "github:nix-community/stylix";
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  flake.aspects.stylix = {
    nixos = {
      imports = [ inputs.stylix.nixosModules.default ];

      stylix = {
        enable = true;
        polarity = lib.mkDefault "dark";
        base16Scheme = lib.mkDefault schemes.dark;
      };

      specialisation = lib.mapAttrs (polarity: scheme: {
        configuration.stylix = {
          inherit polarity;
          base16Scheme = scheme;
        };
      }) schemes;
    };

    homeManager = {
      stylix.targets.kde.enable = false;
    };
  };
}
