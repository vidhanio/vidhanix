final: prev:
let
  readDirContents' =
    cond: path:
    let
      isNixFile = name: type: type == "regular" && prev.hasSuffix ".nix" name;
      isNixFolder =
        name: type: type == "directory" && (prev.pathIsRegularFile "${path}/${name}/default.nix");
      isNixModule = name: type: isNixFile name type || isNixFolder name type;
    in
    prev.pipe (builtins.readDir path) [
      (prev.filterAttrs (name: type: isNixModule name type && cond name))
      prev.attrNames
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
