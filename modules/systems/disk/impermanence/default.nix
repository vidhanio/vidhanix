{ inputs, lib, ... }:
{
  flake-file.inputs.impermanence.url = "github:nix-community/impermanence";

  flake.aspects.disk.provides.impermanence = {
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
            {
              directory = "/var/cache/private";
              mode = "0700";
            }
            "/var/log"
            "/var/lib/nixos"
          ];
          files = [ "/etc/machine-id" ];
        };
        fileSystems.${config.persist.persistentStoragePath}.neededForBoot = true;

        disko.devices.disk.main.content.partitions.root.content.subvolumes.persist = {
          mountpoint = config.persist.persistentStoragePath;
          mountOptions = [
            "compress=zstd"
            "noatime"
          ];
        };
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
