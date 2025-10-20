{
  lib,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";
}
