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

  # NixOS specialisations merge their configuration over the base at equal
  # priority, so the overriding fields need mkForce. Harmless at the Home
  # Manager level, where nothing else defines them.
  specialisation = lib.mapAttrs (_: scheme: {
    configuration.stylix = {
      polarity = lib.mkForce scheme.polarity;
      base16Scheme = lib.mkForce scheme.base16Scheme;
    };
  }) schemes;
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
      }
      // schemes.dark;

      inherit specialisation;
    };

    homeManager = {
      stylix.targets.kde.enable = false;

      inherit specialisation;
    };
  };
}
