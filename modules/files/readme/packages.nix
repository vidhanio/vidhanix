{ lib, self, ... }:
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

          ${config.files.readme.lib.renderTable {
            header = [
              "package"
              "description"
            ];
            rows = map (
              {
                name,
                drv,
                file,
              }:
              [
                "[`${name}`](${file})"
                "${drv.meta.description}"
              ]
            ) packageDefinitions;
          }}
        '';
    };
}
