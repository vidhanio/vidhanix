{ config, ... }:
{
  profiles.base = {
    module.imports = [ config.flake.nixosModules.upstream ];
    homeModule.imports = [ config.flake.homeModules.upstream ];
  };
}
