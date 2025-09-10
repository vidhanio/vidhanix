final: prev:
let
  inherit (prev) lib;
in
with builtins;
lib.mapAttrs' (pname: filetype: {
  name = if filetype == "regular" then lib.removeSuffix ".nix" pname else pname;
  value = prev.callPackage ../pkgs/${pname} { };
}) (readDir ../pkgs)
