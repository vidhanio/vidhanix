{ lib, ... }:
let
  name = "update-packages";
in
{
  perSystem =
    { self', pkgs, ... }:
    let
      # eval-time values (package lists, nix-update path), read from JSON so the .py stays valid before replaceVarsWith.
      config = pkgs.writers.writeJSON "${name}-config.json" {
        known = lib.attrNames self'.packages;

        # `&&` short-circuits before this package's own value is forced (infinite recursion otherwise).
        updatable = lib.attrNames (
          lib.filterAttrs (
            packageName: package: packageName != name && package ? passthru.updateScript
          ) self'.packages
        );

        nixUpdate = lib.getExe pkgs.nix-update;
      };
    in
    {
      packages.${name} = pkgs.replaceVarsWith {
        inherit name;

        src = ./update-packages.py;
        dir = "bin";
        isExecutable = true;

        replacements = {
          python = "${pkgs.python3.withPackages (ps: [ ps.rich ])}/bin/python3";
          config = "${config}";
        };

        meta = {
          description = "Update all packages in this flake that have an update script";
          mainProgram = name;
        };
      };
    };
}
