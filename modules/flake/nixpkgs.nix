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
