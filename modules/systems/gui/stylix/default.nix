{ inputs, ... }: {
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
        polarity = "dark";
        base16Scheme = "${inputs.tinted-schemes}/base16/gruvbox-material-dark-hard.yaml";
      };

    };

    homeManager = {
      stylix.targets.kde.enable = false;
    };
  };
}
