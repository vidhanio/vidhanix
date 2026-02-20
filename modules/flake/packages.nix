{
  lib,
  self,
  ...
}:
{
  perSystem =
    {
      options,
      self',
      config,
      pkgs,
      ...
    }:
    {
      packages.update-packages = pkgs.writeShellApplication {
        name = "update-packages";

        runtimeInputs = with pkgs; [
          nix-update
        ];

        text =
          let
            allpkgs = lib.attrNames (lib.filterAttrs (_: p: p ? passthru.updateScript) self'.packages);
            allpkgsEscaped = lib.escapeShellArgs allpkgs;
          in
          ''
            if [ $# -gt 0 ]; then
              pkgs=("$@")
            else
              pkgs=(${allpkgsEscaped})
            fi

            for pkg in "''${pkgs[@]}"; do
              nix-update --flake --use-update-script --quiet "$pkg"
            done
          '';

        meta.description = "Update all packages in this flake that have an update script";
      };

      files.readme.content.packages.content =
        let
          packageDefinitions = lib.sortOn (p: p.name) (
            lib.concatMap (
              { file, value }:
              # only packages defined in this flake
              lib.optionals (lib.hasPrefix "${self}" file) (
                lib.mapAttrsToList (name: drv: {
                  inherit name drv;
                  # get rid of the nix store prefix and extra suffix
                  file = lib.removePrefix "${self}/" (lib.removeSuffix ", via option perSystem" file);
                }) value
              )
            ) options.packages.definitionsWithLocations
          );
        in
        ''
          this flake has a couple packages, mostly used internally, but available via `.#<package>`.
          some of these packages provide a `passthru.updateScript`, all of which can be run via `nix run .#update-packages`.

          ${config.files.readme.lib.renderTable {
            header = [
              "package"
              "description"
              "has update script"
            ];
            alignments = [
              "l"
              "l"
              "c"
            ];
            rows = map (
              {
                name,
                drv,
                file,
              }:
              [
                "[`${name}`](${file})"
                drv.meta.description
                (lib.optionalString (drv ? passthru.updateScript) "✓")
              ]
            ) packageDefinitions;
          }}
        '';
    };
}
