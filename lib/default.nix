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
      isNixFile = name: type: type == "regular" && prev.hasSuffix ".nix" name;
    in
    prev.pipe (builtins.readDir path) [
      (prev.filterAttrs isNixFile)
      (prev.mapAttrs' (
        name: _: {
          name = prev.removeSuffix ".nix" name;
          value = import (path + "/${name}");
        }
      ))
    ];

  getDesktop' = pkg: name: "${pkg}/share/applications/${name}.desktop";
  getDesktop = pkg: final.getDesktop' pkg (prev.getName pkg);

  maintainers = prev.maintainers // {
    vidhanio = {
      name = "Vidhan Bhatt";
      email = "me@vidhan.io";
      github = "vidhanio";
      githubId = 41439633;
    };
  };
}
