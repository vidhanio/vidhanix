{
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  flake.aspects.home-manager = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.home-manager.nixosModules.default ];

        home-manager = {
          useGlobalPkgs = true;
          backupCommand = lib.getExe pkgs.trash-cli;
        };
      };
    homeManager =
      { osConfig, ... }:
      {
        home.stateVersion = osConfig.system.stateVersion;
      };
  };
}
