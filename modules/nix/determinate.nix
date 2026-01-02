{ inputs, ... }:
{
  flake.modules.nixos.default = {
    imports = [ inputs.determinate.nixosModules.default ];
  };
}
