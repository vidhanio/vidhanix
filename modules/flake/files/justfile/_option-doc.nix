{
  option,
  flake,
  getOptions,
}:
let
  flakeAttrs = builtins.getFlake flake;

  inherit (flakeAttrs.currentSystem.allModuleArgs) pkgs;
  lib = flakeAttrs.inputs.nixpkgs.lib;

  optionsTree = getOptions flakeAttrs;

  # Option records (e.g. `perSystem`) keep their sub-options behind
  # `type.getSubOptions`; plain attrset nodes nest them directly.
  subOptionsOf = node: if lib.isOption node then node.type.getSubOptions node.loc or { } else node;

  # The subtree of `optionsTree` at the dotted `path`.
  select =
    node: path:
    if path == [ ] then
      node
    else
      let
        name = lib.head path;
        rest = lib.tail path;
        subOptions = subOptionsOf node;
      in
      if subOptions ? ${name} then
        { ${name} = select subOptions.${name} rest; }
      else
        throw "no option named '${option}' in the options tree";
in
(pkgs.nixosOptionsDoc {
  options = select optionsTree (lib.splitString "." option);
}).optionsCommonMark
