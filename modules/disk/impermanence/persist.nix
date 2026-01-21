{ inputs, lib, ... }:
{
  flake-file.inputs.impermanence.url = "github:nix-community/impermanence";

  flake.modules = {
    nixos.default =
      { config, ... }:
      {
        imports = [
          inputs.impermanence.nixosModules.default
          (lib.mkAliasOptionModule [ "persist" ] [ "environment" "persistence" "/persist" ])
        ];

        persist = {
          hideMounts = true;
          allowTrash = true;

          directories = [
            "/var/log"
            "/var/lib/nixos"
          ];
          files = [
            "/etc/machine-id"
          ];
        };

        fileSystems.${config.persist.persistentStoragePath}.neededForBoot = true;
      };
    homeManager.default =
      { osConfig, ... }:
      {
        imports = [
          (lib.mkAliasOptionModule
            [ "persist" ]
            [ "home" "persistence" osConfig.persist.persistentStoragePath ]
          )
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
