{ lib, ... }:
{
  home-manager = {
    sharedModules = lib.readSubmodules ./.;
    useGlobalPkgs = true;
  };
}
