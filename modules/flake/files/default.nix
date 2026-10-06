{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      self',
      ...
    }:
    {
      packages.generate-files = pkgs.writeShellApplication {
        name = "generate-files";
        meta = {
          description = "Generate various files for this repository";
          platforms = lib.platforms.linux;
        };
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        text = ''
          ${lib.getExe config.files.writer.drv}

          ${lib.getExe self'.packages.write-flake}
        '';
      };

      pre-commit.settings.hooks.generate-files = {
        enable = true;
        entry = lib.getExe self'.packages.generate-files;
        pass_filenames = false;
      };

      files.readme.content.generated-files.content = ''
        Most of the non-Nix files in this repository (including this very README) are generated via [`just generate`](justfile).
        ${config.files.lib.readme.renderList (
          map (p: "[`${p}`](${p})") (lib.sortOn (p: p) (lib.mapAttrsToList (path: _: path) config.files.file))
        )}
      '';
    };
}
