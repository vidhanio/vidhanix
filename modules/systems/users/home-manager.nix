{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

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
