{ config, ... }:
{
  profiles.base = {
    module = {
      imports = [ config.flake.nixosModules.upstream ];
      i18n.defaultLocale = "en_CA.UTF-8";
      security = {
        sudo.enable = false;
        run0 = {
          enable = true;
          persistentAuth.enable = true;
        };
      };
    };
    homeModule.imports = [ config.flake.homeModules.upstream ];
  };
}
