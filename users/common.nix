{ lib, ... }:
{
  imports = lib.readDirContents ./modules;
}
