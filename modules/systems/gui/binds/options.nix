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
          };
        }
      );
      default = { };
      description = "Keybinds shared across supported window managers.";
    };
  };
}
