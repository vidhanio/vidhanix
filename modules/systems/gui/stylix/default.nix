{
  inputs,
  ...
}:
{
  flake-file.inputs.stylix.url = "github:nix-community/stylix";
  flake-file.prune-lock.ignore = [ "stylix" ];

  flake.aspects.stylix = {
    nixos = {
      imports = [ inputs.stylix.nixosModules.default ];

      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = ./scheme.yaml;
        opacity = {
          applications = 0.25;
          popups = 0.5;
          desktop = 0.25;
          terminal = 0.25;
        };
      };
    };

    homeManager.stylix.targets.kde.enable = false;
  };
}
