{
  inputs,
  ...
}:
{
  flake-file.inputs.stylix.url = "github:vidhanio/stylix/herdr";
  flake-file.prune-lock.ignore = [ "stylix" ];

  flake.modules.nixos.default = {
    imports = [ inputs.stylix.nixosModules.default ];

    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = ./scheme.yaml;
      opacity = {
        desktop = 0.5;
        popups = 0.5;
        applications = 0.5;
        terminal = 0.5;
      };
    };
  };
}
