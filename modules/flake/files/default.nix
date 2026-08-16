{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    let
      # The check sandbox has no nix.conf; bake the experimental features the
      # justfile needs into a wrapper instead.
      nix-cli = pkgs.writeShellScriptBin "nix" ''
        exec ${pkgs.nix}/bin/nix --extra-experimental-features "nix-command flakes" "$@"
      '';
    in
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
        # The hook rebuilds flake outputs, so it needs nix (and just) on PATH;
        # this also lets `nix flake check` run the hook in its sandbox.
        extraPackages = [
          pkgs.hostname
          nix-cli
          pkgs.just
        ];
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
