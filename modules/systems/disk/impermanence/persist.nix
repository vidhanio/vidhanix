{ inputs, lib, ... }:
{
  flake-file.inputs.impermanence.url = "github:nix-community/impermanence";

  den.default = {
    nixos =
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
    homeManager =
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
