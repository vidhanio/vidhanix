final: prev:
let
  inherit (prev) lib;
in
lib.packagesFromDirectoryRecursive {
  inherit (prev) callPackage;
  directory = ../packages;
}
