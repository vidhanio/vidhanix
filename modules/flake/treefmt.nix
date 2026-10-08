{ inputs, ... }:
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
          settings.follow.aliases.nixpkgs = [ "nixpkgs-lib" ];
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
        excludes = [ "*.patch" ];
        on-unmatched = "fatal";
      };
    };
  };
}
