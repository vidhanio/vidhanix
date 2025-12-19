{ lib, ... }:
{
  home-manager = {
    sharedModules = lib.readImportsRecursively ./.;
    useGlobalPkgs = true;
  };
}
