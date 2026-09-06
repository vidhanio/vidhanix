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

      actionOf = action: lib.removeAttrs action [ "_props" ];

      actionType =
        lib.types.addCheck (lib.types.attrsOf kdlType) (
          action: lib.length (lib.attrNames (actionOf action)) == 1
        )
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

            exec = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = if config.app != null then config.app else config.exec;
              defaultText = lib.literalExpression "if config.app != null then config.app else config.exec";
              description = "Command run by the Niri bind.";
            };

            action = lib.mkOption {
              type = lib.types.nullOr actionType;
              description = "Action run by the Niri bind.";
            };
          };

          config.niri.action = lib.mkDerivedConfig options.niri.exec (
            exec: if exec == null then null else { spawn-sh = exec; }
          );
        }
      );

      enabledBinds = lib.filterAttrs (_: bind: bind.niri.enable) config.binds;

      normalizeKey =
        key:
        let
          modifiers = {
            SUPER = "Super";
            SHIFT = "Shift";
            CTRL = "Ctrl";
            CONTROL = "Control";
            ALT = "Alt";
          };
        in
        lib.concatStringsSep "+" (map (part: modifiers.${part} or part) (lib.splitString " + " key));

      renderBind =
        keys: bind:
        let
          cfg = bind.niri;
          props =
            lib.removeAttrs (cfg.action._props or { }) [
              "allow-when-locked"
              "repeat"
            ]
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
        assertions = lib.mapAttrsToList (keys: bind: {
          assertion = !bind.niri.enable || bind.niri.action != null;
          message = "binds.${lib.escapeNixIdentifier keys}.niri must define an action";
        }) config.binds;

        wayland.windowManager.niri.settings.binds = lib.mapAttrs' renderBind enabledBinds;
      };
    };
}
