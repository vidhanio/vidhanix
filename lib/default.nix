lib:
let
  readDirContents' =
    with builtins;
    cond: path: map (name: path + "/${name}") (filter cond (attrNames (readDir path)));
in
rec {
  readDirContents = readDirContents' (_: true);
  readSubmodules = readDirContents' (name: name != "default.nix");

  getDesktop' = pkg: name: "${pkg}/share/applications/${name}.desktop";
  getDesktop = pkg: getDesktop' pkg (lib.getName pkg);
}
