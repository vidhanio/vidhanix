{ inputs, ... }:
{
  flake-file.inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # TODO: drop once https://github.com/NixOS/nixpkgs/pull/554106 lands (fex 2605 -> 2608)
        overlays = [
          (_final: prev: {
            fex = prev.fex.overrideAttrs (old: {
              version = "2608";
              src = old.src.override {
                hash = "sha256-2NdkQpzqDkM/fEW8QYS05KU3JPJeLw4gliryqdOJ3vE=";
              };
            });
          })
        ];
      };
    };
}
