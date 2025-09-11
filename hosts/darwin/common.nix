{ inputs, ... }:
{
  imports = with inputs; [
    determinate.darwinModules.default
    home-manager.darwinModules.default
  ];

  nix.enable = false;
}
