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
        statix.enable = true;
        deadnix.enable = true;

        shfmt.enable = true;
        shellcheck.enable = true;

        actionlint.enable = true;
        yamlfmt.enable = true;

        prettier.enable = true;

        xmllint.enable = true;
      };

      settings.on-unmatched = "fatal";
    };

    pre-commit.settings.hooks.treefmt = {
      enable = true;
      pass_filenames = false;
    };
  };
}
