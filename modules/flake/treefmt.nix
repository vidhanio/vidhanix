{ inputs, lib, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    treefmt = {
      programs = {
        flake-edit = {
          enable = true;
          noLock = true;
          priority = -1;
        };

        nixfmt.enable = true;

        shfmt.enable = true;

        stylua.enable = true;

        ruff-format.enable = true;

        oxfmt.enable = true;

        xmllint.enable = true;

        keep-sorted.enable = true;
      };

      settings = {
        # TODO: Fix treefmt-nix upstream to avoid generating configs for empty settings.
        formatter.flake-edit.options = lib.mkForce [
          "--non-interactive"
          "--no-lock"
          "follow"
        ];
        excludes = [ "*.patch" ];
        on-unmatched = "fatal";
      };
    };
  };
}
