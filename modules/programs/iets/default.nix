{ inputs, ... }:
{
  profiles.base.module = {
    imports = [ inputs.iets.nixosModules.default ];
  };
}
