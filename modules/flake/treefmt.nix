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

        stylua.enable = true;

        actionlint.enable = true;

        ruff-format.enable = true;
        ruff-check.enable = true;

        oxfmt.enable = true;

        xmllint.enable = true;

        keep-sorted.enable = true;
      };

      settings.on-unmatched = "fatal";
    };

    # Resolve `just fmt` from PATH instead of a store binary baked when the
    # hook config was generated; keeps the hook current with the flake state.
    pre-commit.settings.hooks.treefmt = {
      enable = true;
      entry = "just fmt --ci";
      pass_filenames = false;
    };
  };
}
