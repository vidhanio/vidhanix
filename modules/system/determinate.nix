{ inputs, ... }:
{
  profiles.base.module.imports = [ inputs.determinate.nixosModules.default ];
}
