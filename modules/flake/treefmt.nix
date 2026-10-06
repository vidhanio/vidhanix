{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  perSystem = {
    treefmt = {
      programs = {
        nixfmt.enable = true;

        shfmt.enable = true;

        stylua.enable = true;

        ruff-format.enable = true;

        oxfmt.enable = true;

        xmllint.enable = true;

        keep-sorted.enable = true;
      };

      settings = {
        excludes = [ "*.patch" ];
        on-unmatched = "fatal";
      };
    };
  };
}
