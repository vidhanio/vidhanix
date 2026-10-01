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
          This flake has a couple of packages, mostly used internally, but available via `.#<package>`.
          Some of these packages provide a `passthru.updateScript`, all of which can be run via `just update-packages`.

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

          On Apple Silicon, `muvm-steam` starts Valve's ARM64 public beta client inside muvm. The first launch seeds `~/.local/share/Steam/steamrtarm64`, opts into `publicbeta`, and moves an existing `steamrt64` directory to `steamrt64-x86` before linking the native client. The x86 `steam-run` guest remains available for x86 games.
        '';
    };
}
