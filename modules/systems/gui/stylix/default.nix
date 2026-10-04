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
        base16Scheme = "${inputs.tinted-schemes}/base16/tokyo-night-terminal-dark.yaml";
      };
    };

    homeManager = {
      stylix = {
        cornerRadius = 0;
        borderThickness = 2;
        padding = 8;
      };
    };
  };
}
