{ inputs, ... }:
{
  flake.modules.nixos.base = {
    imports = [ inputs.determinate.nixosModules.default ];
  };
}
