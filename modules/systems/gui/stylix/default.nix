{ inputs, ... }: {
  flake-file.inputs.stylix.url = "github:nix-community/stylix";

  flake.aspects.stylix = {
    nixos = {
      imports = [ inputs.stylix.nixosModules.default ];

      stylix = {
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
