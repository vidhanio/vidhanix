{ inputs, lib, ... }:
let
  schemes = {
    dark = {
      polarity = "dark";
      base16Scheme = "${inputs.tinted-schemes}/base16/catppuccin-mocha.yaml";
    };
    light = {
      polarity = "light";
      base16Scheme = "${inputs.tinted-schemes}/base16/catppuccin-latte.yaml";
    };
  };

  # The base defaults mean the specialisations can override with plain values
  # instead of mkForce.
  specialisation = lib.mapAttrs (_: scheme: { configuration.stylix = scheme; }) schemes;
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
        polarity = lib.mkDefault schemes.dark.polarity;
        base16Scheme = lib.mkDefault schemes.dark.base16Scheme;
      };

      inherit specialisation;
    };

    homeManager = {
      stylix.targets.kde.enable = false;
    };
  };
}
