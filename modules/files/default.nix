{ lib, ... }:
{
  perSystem =
    {
      self',
      pkgs,
      config,
      ...
    }:
    {
      packages.generate-files = pkgs.writeShellApplication {
        name = "generate-files";
        meta.description = "Generate various files for this repository";
        text = ''
          # files
          ${lib.getExe config.files.writer.drv}


          lock_bck=$(mktemp)
          cp -p flake.lock "$lock_bck"

          ${lib.getExe config.packages.write-flake}

          # if flake.lock unchanged, restore mtime
          if cmp -s flake.lock "$lock_bck"; then
            touch -r "$lock_bck" flake.lock
          fi
        '';
      };

      pre-commit.settings.hooks.generate-files = {
        enable = true;
        package = self'.packages.generate-files;
        entry = lib.getExe self'.packages.generate-files;
        pass_filenames = false;
      };

      files.readme.content.generated-files.content = ''
        most of the non-nix files in this repository (including this very readme) are generated via [`nix run .#generate-files`](modules/files/default.nix).
        the generated files are:

        ${config.files.readme.lib.renderList (
          map (p: "[`${p}`](${p})") (lib.sortOn (p: p) (map ({ path_, ... }: path_) config.files.files))
        )}
      '';
    };
}
