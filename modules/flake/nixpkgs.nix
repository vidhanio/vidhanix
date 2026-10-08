{ inputs, ... }:
{
  flake-file.inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (_final: _prev: {
            nix = inputs.determinate.inputs.nix.packages.${system}.default;
          })
        ];
      };
    };
}
