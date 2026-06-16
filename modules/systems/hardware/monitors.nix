{ lib, ... }:
let
  monitorType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "The connector name for the monitor.";
      };
      mode = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              width = lib.mkOption {
                type = lib.types.int;
                description = "The monitor width in pixels.";
              };
              height = lib.mkOption {
                type = lib.types.int;
                description = "The monitor height in pixels.";
              };
              refreshRate = lib.mkOption {
                type = lib.types.float;
                description = "The monitor refresh rate in hertz.";
              };
            };
          }
        );
        default = null;
        description = "The monitor mode, or null to use the preferred mode.";
      };
      position = lib.mkOption {
        type = lib.types.submodule {
          options = {
            x = lib.mkOption {
              type = lib.types.int;
              description = "The monitor x position in the layout.";
            };
            y = lib.mkOption {
              type = lib.types.int;
              description = "The monitor y position in the layout.";
            };
          };
        };
        description = "The monitor position in the layout.";
      };
      scale = lib.mkOption {
        type = lib.types.float;
        description = "The monitor scale factor.";
      };
    };
  };
in
{
  flake.modules.nixos.default = {
    options.hardware.monitors = {
      main = lib.mkOption {
        type = monitorType;
        description = "The primary monitor for this system.";
      };
      others = lib.mkOption {
        type = lib.types.listOf monitorType;
        default = [ ];
        description = "Additional monitors for this system.";
      };
    };
  };
}
