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
          applications = 0.75;
          desktop = 0.75;
          popups = 0.75;
          terminal = 0.75;
        };
      };
    };
  };
}
