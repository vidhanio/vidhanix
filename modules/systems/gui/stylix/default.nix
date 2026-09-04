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
          base08 = "ff8080";
          base09 = "ffd280";
          base0A = "ffff80";
          base0B = "408040";
          base0C = "80ffff";
          base0D = "8080ff";
          base0E = "ff80ff";
          base0F = "a55353";
        };
      };
    };

    homeManager = {
      stylix.targets.kde.enable = false;
    };
  };
}
