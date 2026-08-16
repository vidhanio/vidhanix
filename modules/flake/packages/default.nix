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
          this flake has a couple packages, mostly used internally, but available via `.#<package>`.
          some of these packages provide a `passthru.updateScript`, all of which can be run via `just update-packages`.

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
