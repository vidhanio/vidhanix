{ inputs, ... }:
{
  profiles.base.module = {
    imports = [ inputs.bootvine.nixosModules.default ];

    services.bootvine.enable = true;
  };
}
