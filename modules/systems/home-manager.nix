{
  lib,
  inputs,
  config,
  ...
}:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  flake.modules = {
    nixos.default = { pkgs, ... }: {
      imports = [ inputs.home-manager.nixosModules.default ];

      home-manager = {
        sharedModules = with config.flake.modules.homeManager; [ default ];
        useGlobalPkgs = true;
        backupCommand = lib.getExe pkgs.trash-cli;
      };
    };
    homeManager.default =
      { osConfig, ... }:
      {
        home.stateVersion = osConfig.system.stateVersion;
      };
  };
}
