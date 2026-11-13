{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            nix-update = inputs.nix-update.packages.${system}.nix-update.overridePythonAttrs (old: {
              # https://github.com/Mic92/nix-update/issues/687
              patches = old.patches or [ ] ++ [ ./nix-update-flake-prefetch.patch ];
              passthru = old.passthru or { } // {
                nix-update-script =
                  final.callPackage "${prev.path}/pkgs/by-name/ni/nix-update/nix-update-script.nix"
                    { };
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
