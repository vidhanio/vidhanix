{ lib, ... }:
{
  profiles.pc.homeModule = {
    options.desktop.binds = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            cmd = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Command run by the bind.";
            };

            app = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.coercedTo lib.types.str (cmd: { inherit cmd; }) (
                  lib.types.submodule {
                    options = {
                      cmd = lib.mkOption {
                        type = lib.types.str;
                        description = "Command used to launch the application.";
                      };

                      focusAppId = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        description = "Application ID to focus before launching; null always spawns a new instance.";
                      };
                    };
                  }
                )
              );
              default = null;
              description = "Application launched by the bind.";
            };

            locked = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether the bind remains active while the session is locked.";
            };

            repeating = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether holding the bind repeats its action.";
            };
          };
        }
      );
      default = { };
      description = "Keybinds shared across supported window managers.";
    };
  };
}
