{
  lib,
  ...
}:
{
  imports = lib.readDirImportsRecursively ./.;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "26.05";
}
