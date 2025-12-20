{ withSystem, lib, ... }:
{
  flake.modules.homeManager.default =
    { config, pkgs, ... }:
    let
      cfg = config.roms;
    in
    {
      options.roms =
        let
          mkGameType =
            system:
            lib.types.coercedTo lib.types.str (name: { inherit name; }) (
              lib.types.submodule (
                { config, ... }:
                {
                  options = {
                    name = lib.mkOption {
                      type = lib.types.str;
                      description = "The name of the game.";
                    };
                    hash = lib.mkOption {
                      type = lib.types.str;
                      default =
                        if system.romHashes ? ${config.filename} && system.romHashes.${config.filename} != null then
                          builtins.convertHash {
                            hash = system.romHashes.${config.filename};
                            hashAlgo = "sha1";
                            toHashFormat = "sri";
                          }
                        else
                          "";
                      description = "The hash of the game's ROM, as found in the libretro database.";
                    };

                    filename = lib.mkOption {
                      type = lib.types.str;
                      readOnly = true;
                      default = "${config.name}.${system.ext}";
                      description = "The filename of the game's ROM, including extension.";
                    };
                  };
                }
              )
            );

          systemsType = lib.types.attrsOf (
            lib.types.submodule (
              { name, config, ... }:
              {
                options = {
                  brand = lib.mkOption {
                    type = lib.types.str;
                    description = "The brand of the system.";
                  };
                  name = lib.mkOption {
                    type = lib.types.str;
                    description = "The name of the system.";
                  };
                  core = lib.mkOption {
                    type = lib.types.nullOr lib.types.package;
                    description = "The default libretro core to use for this system.";
                  };
                  group = lib.mkOption {
                    type = lib.types.enum [
                      "Redump"
                      "No-Intro"
                    ];
                    description = "The ROM group of this system.";
                  };
                  ext = lib.mkOption {
                    type = lib.types.str;
                    description = "The file extension for ROMs of this system.";
                  };
                  myrientSuffix = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "An optional suffix to append to the system name when fetching from Myrient.";
                  };
                  games = lib.mkOption {
                    type = lib.types.listOf (mkGameType config);
                    default = [ ];
                    description = "Games to download and manage ROMs for this system.";
                  };

                  fullName = lib.mkOption {
                    type = lib.types.str;
                    readOnly = true;
                    description = "The full name of the system, including brand.";
                    default = "${config.brand} - ${config.name}";
                  };
                  romHashes = lib.mkOption {
                    type = lib.types.attrsOf lib.types.str;
                    readOnly = true;
                    description = "A mapping of ROM filenames to their SHA-1 hashes, as found in the libretro database.";
                    default = lib.importJSON (
                      pkgs.runCommand "rom-hashes-${name}.json" { } ''
                        cp "${pkgs.libretro-database}/share/libretro/database/rdb/${config.fullName}.rdb" ./db.rdb
                        chmod u+w ./db.rdb # libretrodb_tool needs write permissions
                        { ${lib.getExe pkgs.libretrodb-tool} ./db.rdb list || true; } \
                          | sed 's/\t/\\t/g' \
                          | ${lib.getExe pkgs.jq} -s 'map(select(.rom_name != null) | { key: .rom_name, value: .sha1 }) | from_entries' > $out
                      ''
                    );
                  };
                  romsPackage = lib.mkOption {
                    type = lib.types.package;
                    readOnly = true;
                    description = ''
                      A directory derivation containing all the downloaded game ROMs for this system.
                    '';
                    default = pkgs.linkFarm "${name}-roms" (
                      lib.genAttrs' config.games (
                        game:
                        lib.nameValuePair game.filename (
                          withSystem pkgs.stdenv.hostPlatform.system (
                            { self', ... }:
                            self'.packages.fetchMyrient {
                              inherit (config) group ext;
                              system = "${config.fullName}${config.myrientSuffix}";
                              game = game.name;
                              inherit (game) hash;
                            }
                          )
                        )
                      )
                    );
                  };
                };
              }
            )
          );
        in
        {
          enable = lib.mkEnableOption "downloading and management of video game ROMs for emulated systems";
          systems = lib.mkOption {
            type = systemsType;
            description = "Emulated systems this module can manage game ROMs for.";
          };
          directory = lib.mkOption {
            type = lib.types.str;
            default = "Games/ROMs";
            description = ''
              Path to the directory to store the downloaded video game ROMs, relative to the home directory.
            '';
          };
          romsPackage = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            readOnly = true;
            description = ''
              A directory derivation containing directories for each emulated system, each containing all the downloaded game ROMs for that system.
            '';
            default = pkgs.linkFarm "roms" (
              lib.mapAttrs' (_: system: lib.nameValuePair system.fullName system.romsPackage) (
                lib.filterAttrs (_: system: system.games != [ ]) cfg.systems
              )
            );
          };
        };

      config = lib.mkMerge [
        {
          roms.systems = {
            nes = {
              brand = "Nintendo";
              name = "Nintendo Entertainment System";
              core = pkgs.libretro.mesen;
              group = "No-Intro";
              ext = "nes";
              myrientSuffix = " (Headered)";
            };

            n64 = {
              brand = "Nintendo";
              name = "Nintendo 64";
              core = pkgs.libretro.mupen64plus;
              group = "No-Intro";
              ext = "z64";
              myrientSuffix = " (BigEndian)";
            };

            gamecube = {
              brand = "Nintendo";
              name = "GameCube";
              core = pkgs.libretro.dolphin;
              group = "Redump";
              ext = "rvz";
              myrientSuffix = " - NKit RVZ [zstd-19-128k]";
            };

            wii = {
              brand = "Nintendo";
              name = "Wii";
              core = pkgs.libretro.dolphin;
              group = "Redump";
              ext = "rvz";
              myrientSuffix = " - NKit RVZ [zstd-19-128k]";
            };
          };
        }
        (lib.mkIf cfg.enable {
          programs = {
            dolphin-emu.gamesDirectories = lib.filter (pkg: pkg != null) [
              cfg.systems.gamecube.romsPackage
              cfg.systems.wii.romsPackage
            ];

            retroarch = {
              cores = lib.mapAttrs (_name: system: {
                enable = system.games != [ ];
                package = system.core;
              }) cfg.systems;

              settings = {
                rgui_browser_directory = "~/${cfg.directory}";
              };
            };
          };

          home.file.${cfg.directory}.source = cfg.romsPackage;
        })
      ];
    };
}
