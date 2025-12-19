final: prev: {
  readDirImportsRecursively =
    path:
    let
      processEntry =
        name: type:
        let
          fullPath = path + "/${name}";
        in
        if type == "regular" && prev.hasSuffix ".nix" name && name != "default.nix" then
          [ fullPath ]
        else if type == "directory" then
          if (prev.pathIsRegularFile (fullPath + "/default.nix")) then
            [ (fullPath + "/default.nix") ]
          else
            final.readDirImportsRecursively fullPath
        else
          [ ];
    in
    prev.concatLists (prev.mapAttrsToList processEntry (builtins.readDir path));

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
