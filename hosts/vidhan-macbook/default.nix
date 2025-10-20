{
  lib,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "25.11";
}
