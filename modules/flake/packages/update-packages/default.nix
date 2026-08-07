{ lib, ... }:
let
  name = "update-packages";
in
{
  perSystem =
    { self', pkgs, ... }:
    let
      # the package lists and the path of nix-update are known at evaluation
      # time; the script reads them from this file, so that the source stays
      # valid python before `replaceVarsWith` fills in the placeholders.
      config = pkgs.writers.writeJSON "${name}-config.json" {
        known = lib.attrNames self'.packages;

        # `&&` short-circuits before this package's own value is forced.
        # that value depends on this list, so forcing it here is infinite
        # recursion. this package carries no update script anyway.
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
