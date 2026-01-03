{ inputs, ... }:
{
  flake-file.inputs.determinate.url = "github:DeterminateSystems/determinate";

  flake.modules.nixos.default = {
    imports = [ inputs.determinate.nixosModules.default ];
  };
}
