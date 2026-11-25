{ inputs, lib, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = { pkgs, ... }: {
    treefmt = {
      programs = {
        flake-edit = {
          enable = true;
          includes = [
            "flake.nix"
            "*.flake.nix"
          ];
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
        formatter.nufmt = {
          command = lib.getExe pkgs.nufmt;
          includes = [ "*.nu" ];
          stdin-options = [ "--stdin" ];
        };
        excludes = [
          "*.patch"
          "modules/programs/steam/team-fortress-2/assets/**"
        ];
        on-unmatched = "fatal";
      };
    };
  };
}
