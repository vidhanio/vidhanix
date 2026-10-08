{ lib, ... }:
{
  perSystem =
    { config, ... }:
    {
      files.writer.app = true;

      files.readme.content.generated-files.content = ''
        Definitions under `modules/flake/files/` produce the following files. Regenerate them with [`just generate`](justfile).

        ${config.files.lib.readme.renderList (
          map (p: "[`${p}`](${p})") (lib.sortOn (p: p) (lib.mapAttrsToList (path: _: path) config.files.file))
        )}
      '';
    };
}
