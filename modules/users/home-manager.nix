{
  lib,
  inputs,
  ...
}:
{
  profiles.base = {
    module =
      { pkgs, ... }:
      {
        imports = [ inputs.home-manager.nixosModules.default ];

        home-manager = {
          useGlobalPkgs = true;
          backupCommand = lib.getExe pkgs.trash-cli;
        };
      };
    homeModule =
      { osConfig, ... }:
      {
        home.stateVersion = osConfig.system.stateVersion;
      };
  };
}
