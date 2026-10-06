{ config, ... }:
{
  profiles.pc = {
    module.imports = [ config.profiles.base.module ];
    homeModule.imports = [ config.profiles.base.homeModule ];
  };
}
