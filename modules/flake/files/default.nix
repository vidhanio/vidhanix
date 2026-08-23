{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    let
      # the check sandbox has no nix.conf; bake the experimental features the
      # justfile needs into a wrapper instead.
      nix-cli = pkgs.writeShellScriptBin "nix" ''
        exec ${pkgs.nix}/bin/nix --extra-experimental-features "nix-command flakes" "$@"
      '';
    in
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

          ${lib.getExe config.packages.write-flake}
        '';
      };

      # run `just generate` instead of a pre-built binary, so the hook rebuilds
      # from the current flake state rather than a stale baked store path.
      pre-commit.settings.hooks.generate-files = {
        enable = true;
        entry = "just generate";
        pass_filenames = false;
        # the hook rebuilds flake outputs, so it needs nix (and just) on PATH;
        # this also lets `nix flake check` run the hook in its sandbox.
        extraPackages = [
          pkgs.hostname
          nix-cli
          pkgs.just
        ];
      };

      files.readme.content.generated-files.content = ''
        Most of the non-Nix files in this repository (including this very README) are generated via [`just generate`](justfile).
        ${config.files.lib.readme.renderList (
          map (p: "[`${p}`](${p})") (lib.sortOn (p: p) (lib.mapAttrsToList (path: _: path) config.files.file))
        )}
      '';
    };
}
