{ inputs, lib, ... }:
let
  path = "/persist";
in
{
  # https://github.com/nix-community/impermanence/pull/288
  flake-file.inputs.impermanence.url = "github:vidhanio/impermanence/trash";

  flake.modules = {
    nixos.default = {
      imports = [
        inputs.impermanence.nixosModules.default
        (lib.mkAliasOptionModule [ "persist" ] [ "environment" "persistence" path ])
      ];

      persist = {
        hideMounts = true;
        allowTrash = true;

        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/tmp"
        ];
        files = [
          "/etc/machine-id"
        ];
      };

      fileSystems.${path}.neededForBoot = true;
    };
    homeManager.default = {
      imports = [
        (lib.mkAliasOptionModule [ "persist" ] [ "home" "persistence" path ])
      ];

      persist = {
        hideMounts = true;
        allowTrash = true;

        directories = [
          "Downloads"
          "Projects"

          ".cache/nix"
        ];
      };
    };
  };
}
