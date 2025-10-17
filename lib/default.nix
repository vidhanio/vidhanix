final: prev:
let
  readDirContents' =
    let
      isNixModule = name: type: (type == "regular" && prev.hasSuffix ".nix" name) || type == "directory";
    in
    with builtins;
    cond: path:
    prev.pipe (readDir path) [
      (prev.filterAttrs (name: type: isNixModule name type && cond name))
      attrNames
      (map (name: path + "/${name}"))
    ];
in
{
  readDirContents = readDirContents' (_: true);
  readSubmodules = readDirContents' (name: name != "default.nix");

  importDirAttrs =
    path:
    let
      dir = builtins.readDir path;
      isNixFile = name: type: type == "regular" && prev.hasSuffix ".nix" name;
      nixFiles = prev.filterAttrs isNixFile dir;
    in
    prev.mapAttrs' (name: _: {
      name = prev.removeSuffix ".nix" name;
      value = import (path + "/${name}");
    }) nixFiles;

  getDesktop' = pkg: name: "${pkg}/share/applications/${name}.desktop";
  getDesktop = pkg: final.getDesktop' pkg (prev.getName pkg);
}
