{ lib, ... }:
{
  flake.aspects.binds.homeManager =
    { config, ... }:
    let
      kdlType = lib.types.nullOr (
        lib.types.oneOf [
          lib.types.bool
          lib.types.int
          lib.types.float
          lib.types.str
          (lib.types.attrsOf kdlType)
          (lib.types.listOf kdlType)
        ]
      );

      actionType =
        lib.types.addCheck (lib.types.attrsOf kdlType) (action: lib.length (lib.attrNames action) == 1)
        // {
          description = "Niri bind naming exactly one action";
          descriptionClass = "noun";
        };

      bindType = lib.types.submodule (
        { config, options, ... }:
        {
          options.niri = {
            enable = lib.mkEnableOption "this bind for Niri" // {
              default = true;
            };

            locked = lib.mkOption {
              type = lib.types.bool;
              default = config.locked;
              defaultText = lib.literalExpression "config.locked";
              description = "Whether the Niri bind remains active while locked.";
            };

            repeating = lib.mkOption {
              type = lib.types.bool;
              default = config.repeating;
              defaultText = lib.literalExpression "config.repeating";
              description = "Whether holding the Niri bind repeats its action.";
            };

            cmd = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = if config.app != null then config.app else config.cmd;
              defaultText = lib.literalExpression "if config.app != null then config.app else config.cmd";
              description = "Command run by the Niri bind.";
            };

            props = lib.mkOption {
              type = lib.types.attrsOf kdlType;
              default = { };
              description = "Properties applied to the Niri bind.";
            };

            action = lib.mkOption {
              type = lib.types.nullOr actionType;
              description = "Action run by the Niri bind.";
            };
          };

          config.niri.action = lib.mkIf (config.niri.cmd != null) (
            lib.mkDerivedConfig options.niri.cmd (cmd: {
              spawn-sh = cmd;
            })
          );
        }
      );

      enabledBinds = lib.filterAttrs (_: bind: bind.niri.enable && bind.niri.action != null) config.binds;

      normalizeKey =
        key:
        let
          modifiers = {
            SUPER = "Super";
            SHIFT = "Shift";
            CTRL = "Ctrl";
            ALT = "Alt";
            mouse_down = "WheelScrollDown";
            mouse_up = "WheelScrollUp";
          };
        in
        lib.concatStringsSep "+" (map (part: modifiers.${part} or part) (lib.splitString " + " key));

      renderBind =
        keys: bind:
        let
          cfg = bind.niri;
          props =
            cfg.props
            // lib.optionalAttrs cfg.locked { allow-when-locked = true; }
            // {
              repeat = cfg.repeating;
            };
        in
        lib.nameValuePair (normalizeKey keys) (
          cfg.action
          // {
            _props = props;
          }
        );
    in
    {
      options.binds = lib.mkOption {
        type = lib.types.attrsOf bindType;
      };

      config = {
        wayland.windowManager.niri.settings.binds = lib.mapAttrs' renderBind enabledBinds;
      };
    };
}
