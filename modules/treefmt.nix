{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  perSystem.treefmt = {
    programs = {
      nixfmt.enable = true;
      statix.enable = true;
      deadnix.enable = true;

      shfmt.enable = true;
      shellcheck.enable = true;
    };
  };
}
