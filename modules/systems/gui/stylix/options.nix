{ lib, ... }:
{
  flake.aspects.stylix.homeManager = {
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
  };
}
