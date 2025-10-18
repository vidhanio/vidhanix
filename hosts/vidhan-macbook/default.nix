{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  nixpkgs.hostPlatform = "aarch64-linux";

  nix.settings = {
    cores = 1;
    max-jobs = 2;
  };

  system.stateVersion = "25.11";
}
