{
  lib,
  self,
  ...
}:
{
  perSystem =
    {
      options,
      config,
      ...
    }:
    {
      files.readme.content.packages.content =
        let
          packageDefinitions = lib.sortOn (p: p.name) (
            lib.concatMap (
              { file, value }:
              lib.optionals (lib.hasPrefix "${self}" file) (
                lib.mapAttrsToList (name: drv: {
                  inherit name drv;
                  file = lib.removePrefix "${self}/" (lib.removeSuffix ", via option perSystem" file);
                }) value
              )
            ) options.packages.definitionsWithLocations
          );
        in
        ''
          Build packages with `nix build .#<package>`.
          Run available `passthru.updateScript` hooks with `just update-packages`; pass package names to update a subset.

          ${config.files.lib.readme.renderTable {
            header = [
              "Package"
              "Description"
              "Updatable"
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
