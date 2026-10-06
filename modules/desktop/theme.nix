{ inputs, lib, ... }:
{
  flake-file.inputs = {
    stylix.url = "github:nix-community/stylix";
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  profiles.pc = {
    module.stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${inputs.tinted-schemes}/base16/tokyo-night-terminal-dark.yaml";
    };

    homeModule = {
      options.stylix = {
        cornerRadius = lib.mkOption {
          type = lib.types.ints.unsigned;
          description = "Shared corner radius in logical pixels.";
        };
        borderThickness = lib.mkOption {
          type = lib.types.ints.unsigned;
          description = "Shared border thickness in logical pixels.";
        };
        padding = lib.mkOption {
          type = lib.types.ints.unsigned;
          description = "Shared interface padding in logical pixels.";
        };
      };
      config.stylix = {
        cornerRadius = 0;
        borderThickness = 2;
        padding = 8;
      };
    };
  };
}
