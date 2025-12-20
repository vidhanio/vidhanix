{
  flake.modules.homeManager.default =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.programs.dolphin-emu;

      ini = pkgs.formats.ini { };
    in
    {
      options.programs.dolphin-emu = {
        enable = lib.mkEnableOption "Dolphin emulator";
        package = lib.mkPackageOption pkgs "dolphin-emu" { };
        gamesDirectories = lib.mkOption {
          type = lib.types.listOf (lib.types.either lib.types.str lib.types.path);
          default = [ ];
          description = ''
            Paths to directories containing games for Dolphin to scan on startup.
          '';
        };
        settings = lib.mkOption {
          inherit (ini) type;
          default = { };
          apply =
            let
              # true -> True, false -> False
              valueApply = value: if lib.isBool value then (if value then "True" else "False") else value;
            in
            settings: lib.mapAttrs (_: section: lib.mapAttrs (_: valueApply) section) settings;
          description = ''
            Dolphin emulator settings written to
            {file}`$XDG_CONFIG_HOME/dolphin-emu/Dolphin.ini`.
          '';
        };
      };

      config = lib.mkMerge [
        {
          programs.dolphin-emu.settings = {
            General = lib.mkIf (cfg.gamesDirectories != [ ]) (
              {
                ISOPaths = lib.length cfg.gamesDirectories;
              }
              // lib.listToAttrs (
                lib.imap0 (i: path: lib.nameValuePair "ISOPath${toString i}" "${path}") cfg.gamesDirectories
              )
            );
          };
        }
        (lib.mkIf cfg.enable {
          home.packages = [ cfg.package ];

          xdg.configFile."dolphin-emu/Dolphin.ini" = lib.mkIf (cfg.settings != { }) {
            source = ini.generate "dolphin-emu-settings" cfg.settings;
            force = true;
          };
        })
      ];
    };
}
