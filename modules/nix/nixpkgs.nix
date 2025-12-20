{
  inputs,
  withSystem,
  ...
}:
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

  flake.modules.nixos.default =
    { config, ... }:
    {
      nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system ({ pkgs, ... }: pkgs);
    };
}
