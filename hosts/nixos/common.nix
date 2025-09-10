{ inputs, ... }:
{
  imports = with inputs; [
    determinate.nixosModules.default
    home-manager.nixosModules.default
  ];
}
