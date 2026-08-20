{ inputs, lib, ... }:
{
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  flake.aspects.preservation = {
    nixos =
      { config, options, ... }:
      let
        preserveAtOptions = options.preservation.preserveAt.type.getSubOptions [ ];
        preservationUserType = preserveAtOptions.users.type;
        # the reused entry types materialize mount defaults that preservation adds again when consumed.
        removeDefaultMountOptions =
          defaults:
          map (
            entry:
            entry
            // {
              mountOptions = lib.filter (option: !lib.elem option.name defaults) entry.mountOptions;
            }
          );
      in
      {
        imports = [
          inputs.preservation.nixosModules.default
          (lib.mkAliasOptionModule [ "persist" ] [ "preservation" "preserveAt" "/persist" ])
        ];

        home-manager.sharedModules = [
          (
            { config, ... }:
            let
              userOptions = preservationUserType.getSubOptions [ config.home.username ];
              # reuse preservation's entry type without the list option's home-prefixing apply function.
              withoutHomePrefix =
                option:
                let
                  entryType = option.type.nestedTypes.elemType;
                in
                lib.types.listOf (
                  entryType.substSubModules (
                    entryType.getSubModules ++ [ { _module.args.defaultOwner = lib.mkForce config.home.username; } ]
                  )
                );
            in
            {
              options.persist = {
                directories = lib.mkOption {
                  type = withoutHomePrefix userOptions.directories;
                  default = [ ];
                  inherit (userOptions.directories) description;
                };
                files = lib.mkOption {
                  type = withoutHomePrefix userOptions.files;
                  default = [ ];
                  inherit (userOptions.files) description;
                };
              };
            }
          )
        ];

        preservation.enable = true;
        persist = {
          commonMountOptions = [
            "x-gvfs-hide"
            "x-gvfs-trash"
          ];
          directories = [
            "/var/log"
            "/var/lib/nixos"
          ];
          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
          ];
          users = lib.mapAttrs (_username: homeConfig: {
            home = homeConfig.home.homeDirectory;
            directories = removeDefaultMountOptions [
              "bind"
              "X-fstrim.notrim"
            ] homeConfig.persist.directories;
            files = removeDefaultMountOptions [ "bind" ] homeConfig.persist.files;
          }) config.home-manager.users;
        };

        fileSystems.${config.persist.persistentStoragePath}.neededForBoot = true;
        systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
      };

    homeManager = {
      persist.directories = [
        "Downloads"
        "Projects"
        ".cache/nix"
      ];
    };
  };
}
