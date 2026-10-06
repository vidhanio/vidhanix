{ inputs, ... }: {
  flake-file.inputs = {
    stylix.url = "github:nix-community/stylix";
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  profiles.pc = {
    module = {
      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = "${inputs.tinted-schemes}/base16/tokyo-night-terminal-dark.yaml";
      };
    };

    homeModule = {
      stylix = {
        cornerRadius = 0;
        borderThickness = 2;
        padding = 8;
      };
    };
  };
}
