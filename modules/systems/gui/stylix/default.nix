{ inputs, lib, ... }: {
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
        base16Scheme = lib.mkDefault "${inputs.tinted-schemes}/base16/catppuccin-mocha.yaml";
      };

    };

    homeManager = {
      stylix.targets.kde.enable = false;
    };
  };
}
