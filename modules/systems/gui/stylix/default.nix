{ inputs, ... }:
{
  flake-file.inputs.stylix.url = "github:nix-community/stylix";

  flake.aspects.stylix = {
    nixos = {
      imports = [ inputs.stylix.nixosModules.default ];

      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = ./scheme.yaml;
      };
    };

    homeManager.stylix.targets.kde.enable = false;
  };
}
