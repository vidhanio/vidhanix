{ inputs, ... }:
{
  flake-file.inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
}
