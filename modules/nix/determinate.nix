{ inputs, ... }:
{
  flake-file.inputs.determinate.url = "github:DeterminateSystems/determinate";
  flake-file.inputs.determinate-nix.url = "github:DeterminateSystems/nix-src";

  flake.modules.nixos.default = {
    imports = [ inputs.determinate.nixosModules.default ];
  };
}
