lib:
let
  readDirContents' =
    let
      isNixModule = name: type: (type == "regular" && lib.hasSuffix ".nix" name) || type == "directory";
    in
    with builtins;
    cond: path:
    lib.pipe (readDir path) [
      (lib.filterAttrs (name: type: isNixModule name type && cond name))
      attrNames
      (map (name: path + "/${name}"))
    ];
in
rec {
  readDirContents = readDirContents' (_: true);
  readSubmodules = readDirContents' (name: name != "default.nix");

  importDirAttrs =
    path:
    let
      isNixFile = name: type: type == "regular" && lib.hasSuffix ".nix" name;
    in
    lib.pipe (builtins.readDir path) [
      (lib.filterAttrs isNixFile)
      (lib.mapAttrs' (
        name: _: {
          name = lib.removeSuffix ".nix" name;
          value = import (path + "/${name}");
        }
      ))
    ];

  getDesktop' = pkg: name: "${pkg}/share/applications/${name}.desktop";
  getDesktop = pkg: getDesktop' pkg (lib.getName pkg);
}
