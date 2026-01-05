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

          # flake-file
          ${lib.getExe config.packages.write-flake}
        '';
      };

      pre-commit.settings.hooks.generate-files = {
        enable = true;
        package = self'.packages.generate-files;
        entry = lib.getExe self'.packages.generate-files;
      };

      treefmt.settings.global.excludes = map ({ path_, ... }: path_) config.files.files;

      files.readme.content.generated-files.content = ''
        most of the non-nix files in this repository (including this very readme) are generated via [`nix run .#generate-files`](modules/files/default.nix).
        the generated files are:

        ${config.files.readme.lib.renderList (
          map (p: "[`${p}`]") (lib.sortOn (p: p) (map ({ path_, ... }: path_) config.files.files))
        )}
      '';
    };
}
