{ lib, ... }:
{
  profiles.pc.homeModule = {
    options.desktop.workspaces = lib.mkOption {
      default = { };
      description = "Named workspaces shared across supported compositors.";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            apps = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Exact app IDs placed on this workspace at session startup.";
            };
            output = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Output name, or null for the main output.";
            };
            index = lib.mkOption {
              type = lib.types.ints.between 1 10;
              default = 1;
              description = "Workspace index within its output's ten-workspace block.";
            };
          };
        }
      );
    };
  };
}
