{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      packages.generate-files = pkgs.writeShellApplication {
        name = "generate-files";
        meta.description = "Generate various files for this repository";
        derivationArgs = {
          preferLocalBuild = true;
          allowSubstitutes = false;
        };
        text = ''
          ${lib.getExe config.files.writer.drv}

          ${lib.getExe config.packages.write-flake}
        '';
      };

      # Run `just generate` instead of a pre-built binary: the hook then
      # resolves `just` and rebuilds `generate-files` from the current flake
      # state, instead of running a stale store path baked when the hook
      # config was generated.
      pre-commit.settings.hooks.generate-files = {
        enable = true;
        entry = "just generate";
        pass_filenames = false;
      };

      readme.content.generated-files.content = ''
        most of the non-nix files in this repository (including this very readme) are generated via [`just generate`](justfile).
        the generated files are:

        ${config.readme.lib.renderList (
          map (p: "[`${p}`](${p})") (lib.sortOn (p: p) (lib.mapAttrsToList (path: _: path) config.files.file))
        )}
      '';
    };
}
