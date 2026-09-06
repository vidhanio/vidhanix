{ lib, ... }:
{
  flake.aspects.binds.homeManager = {
    options.binds = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            exec = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Command run by the bind.";
            };

            app = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
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
