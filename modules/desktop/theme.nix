{ lib, ... }:
{
  profiles.pc = {
    module.stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = {
        scheme = "Vidhan";
        slug = "vidhan";
        author = "Vidhan Bhatt (https://vidhan.io)";
        variant = "dark";

        base00 = "000000";
        base01 = "151515";
        base02 = "2b2b2b";
        base03 = "404040";
        base04 = "bfbfbf";
        base05 = "d5d5d5";
        base06 = "eaeaea";
        base07 = "ffffff";
        base08 = "ff8080";
        base09 = "ffc080";
        base0A = "ffff80";
        base0B = "80ff80";
        base0C = "80ffff";
        base0D = "8080ff";
        base0E = "ff80ff";
        base0F = "c08040";
      };
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
        cornerRadius = 4;
        borderThickness = 2;
        padding = 8;
      };
    };
  };
}
