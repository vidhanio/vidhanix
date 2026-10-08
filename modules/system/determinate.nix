{ inputs, ... }:
{
  perSystem.treefmt.programs.flake-edit.settings.follow.ignore = [
    "determinate.nixpkgs"
    "determinate.nix.nixpkgs"
  ];

  profiles.base.module.imports = [ inputs.determinate.nixosModules.default ];
}
