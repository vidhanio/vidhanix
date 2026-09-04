{ inputs, ... }: {
  flake-file.inputs.stylix.url = "github:nix-community/stylix";

  flake.aspects.stylix = {
    nixos = {
      imports = [ inputs.stylix.nixosModules.default ];

      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = {
          scheme = "Default";
          slug = "default";
          base00 = "000000";
          base01 = "242424";
          base02 = "494949";
          base03 = "6d6d6d";
          base04 = "929292";
          base05 = "b6b6b6";
          base06 = "dbdbdb";
          base07 = "ffffff";
          base08 = "ff0000";
          base09 = "ffa500";
          base0A = "ffff00";
          base0B = "008000";
          base0C = "00ffff";
          base0D = "0000ff";
          base0E = "ff00ff";
          base0F = "a52a2a";
        };
      };
    };

    homeManager = {
      stylix.targets.kde.enable = false;
    };
  };
}
