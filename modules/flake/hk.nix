{ inputs, lib, ... }:
{
  imports = [
    inputs.hk-nix.flakeModules.default
  ];
  perSystem =
    { config, pkgs, ... }:
    {
      # Builtins read the source during evaluation; avoid import-from-derivation.
      hk-nix.hkSrc = builtins.fetchTarball {
        inherit (config.hk-nix.package.src) url;
        sha256 = config.hk-nix.package.src.outputHash;
      };

      hk-nix.settings.hooks."pre-commit" = {
        fix = true;
        stage = false;
        fail_on_fix = true;
        stash = "git";
        steps = {
          deadnix.builtin = config.hk-nix.builtins.deadnix;
          ruff.builtin = config.hk-nix.builtins.ruff;
          shellcheck = {
            builtin = config.hk-nix.builtins.shellcheck;
            match_any = [
              { __pkl = ''new FileSelector { types = List("shell") }''; }
              { __pkl = ''new FileSelector { glob = ".envrc" }''; }
            ];
          };
          statix = {
            glob = "**/*.nix";
            check = "${lib.getExe pkgs.statix} check";
          };
          treefmt = {
            check = "${lib.getExe config.treefmt.build.wrapper} --fail-on-change --no-cache {{files}}";
            fix = "${lib.getExe config.treefmt.build.wrapper} --no-cache {{files}}";
          };
          ty = {
            builtin = config.hk-nix.builtins.ty;
            # Resolve third-party imports against the project's Python environment.
            check = "${lib.getExe pkgs.ty} check --python ${
              lib.getExe (pkgs.python3.withPackages (ps: [ ps.rich ]))
            } {{files}}";
          };
          write-files = {
            depends = [ "treefmt" ];
            stage = lib.attrNames config.files.file;
            check = lib.getExe (
              pkgs.writeShellApplication {
                name = "check-generated-files";
                runtimeInputs = [ pkgs.diffutils ];
                text = lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (
                    path: file: "diff --unified ${lib.escapeShellArg path} ${file.source}"
                  ) config.files.file
                );
              }
            );
            fix = lib.getExe config.files.writer.drv;
          };
        };
      };
    };
}
