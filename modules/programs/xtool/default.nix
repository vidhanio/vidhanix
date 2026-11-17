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
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
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
