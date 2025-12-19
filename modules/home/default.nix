{ lib, ... }:
{
  home-manager = {
    sharedModules = lib.readDirImportsRecursively ./.;
    useGlobalPkgs = true;
  };
}
