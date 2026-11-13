{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # Steam's ARM64 client still links against GTK 2, pending upstream migration.
        config.problems.handlers."gtk+".broken = "warn";
        overlays = [
          (final: prev: {
            nix-update = inputs.nix-update.packages.${system}.nix-update.overridePythonAttrs (old: {
              # https://github.com/Mic92/nix-update/issues/687
              patches = old.patches or [ ] ++ [ ./nix-update-flake-prefetch.patch ];
              passthru = old.passthru or { } // {
                nix-update-script = prev.nix-update.nix-update-script.override { inherit (final) nix-update; };
              };
              meta = old.meta or { } // {
                mainProgram = "nix-update";
              };
            });
          })
        ];
      };
    };
}
