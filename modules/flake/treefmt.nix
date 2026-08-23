{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  perSystem =
    { pkgs, ... }:
    let
      # the check sandbox has no nix.conf; bake the experimental features the
      # justfile needs into a wrapper instead.
      nix-cli = pkgs.writeShellScriptBin "nix" ''
        exec ${pkgs.nix}/bin/nix --extra-experimental-features "nix-command flakes" "$@"
      '';
    in
    {
      treefmt = {
        programs = {
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;

          shfmt.enable = true;
          shellcheck.enable = true;

          stylua.enable = true;

          ruff-format.enable = true;
          ruff-check.enable = true;

          oxfmt.enable = true;

          xmllint.enable = true;

          keep-sorted.enable = true;
        };

        settings = {
          # patches are immutable diffs, so skip them.
          excludes = [ "*.patch" ];
          on-unmatched = "fatal";
        };
      };

      # resolve `just fmt` from PATH instead of a store binary baked when the
      # hook config was generated; keeps the hook current with the flake state.
      pre-commit.settings.hooks.treefmt = {
        enable = true;
        entry = "just fmt --ci";
        pass_filenames = false;
        extraPackages = [
          pkgs.hostname
          nix-cli
          pkgs.just
        ];
      };
    };
}
