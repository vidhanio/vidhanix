{ inputs, ... }:
{
  profiles.pc = {
    module =
      { inputs', ... }:
      {
        # TODO: https://github.com/NixOS/nixpkgs/pull/548520
        imports = [ "${inputs.nixpkgs-xtool}/nixos/modules/programs/xtool.nix" ];

        programs.xtool = {
          enable = true;
          package = inputs'.nixpkgs-xtool.legacyPackages.xtool;
        };
      };

    homeModule =
      { inputs', ... }:
      {
        home.packages = with inputs'.nixpkgs-xtool.legacyPackages; [
          swift
          swiftpm
        ];

        persist.directories = [
          ".config/swiftpm"
          ".config/xtool"
        ];
      };
  };
}
