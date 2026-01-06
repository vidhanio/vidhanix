{ inputs, lib, ... }:
let
  path = "/persist";
in
{
  # https://github.com/nix-community/impermanence/pull/272
  # https://github.com/nix-community/impermanence/pull/243
  flake-file.inputs.impermanence.url = "github:vidhanio/impermanence/hmv2-trash";

  flake.modules = {
    nixos.default =
      { config, ... }:
      let
        cfg = config.persist;
      in
      {
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

        fileSystems.${cfg.persistentStoragePath}.neededForBoot = true;
      };
    homeManager.default =
      { ... }:
      {
        imports = [
          inputs.impermanence.homeManagerModules.default
          (lib.mkAliasOptionModule [ "persist" ] [ "home" "persistence" path ])
        ];

        persist = {
          hideMounts = true;
          allowTrash = true;
        };
      };
  };
}
