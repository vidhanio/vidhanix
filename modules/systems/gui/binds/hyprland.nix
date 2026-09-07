{ lib, ... }:
{
  flake.aspects.binds.homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      lua = pkgs.formats.lua { };
      toLua = lib.generators.toLua { multiline = false; };

      dispatcherOf = lib.id;

      dspType =
        lib.types.addCheck (lib.types.attrsOf lua.type) (
          dsp: lib.length (lib.attrNames (dispatcherOf dsp)) == 1
        )
        // {
          description = "Hyprland bind naming exactly one dispatcher";
          descriptionClass = "noun";
        };

      bindType = lib.types.submodule (
        { config, options, ... }:
        {
          options.hyprland = {
            enable = lib.mkEnableOption "this bind for Hyprland" // {
              default = true;
            };

            locked = lib.mkOption {
              type = lib.types.bool;
              default = config.locked;
              defaultText = lib.literalExpression "config.locked";
              description = "Whether the Hyprland bind remains active while locked.";
            };

            repeating = lib.mkOption {
              type = lib.types.bool;
              default = config.repeating;
              defaultText = lib.literalExpression "config.repeating";
              description = "Whether holding the Hyprland bind repeats its action.";
            };

            cmd = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Command run by the Hyprland bind.";
            };

            dsp = lib.mkOption {
              type = lib.types.nullOr dspType;
              default = null;
              description = "Hyprland dispatcher called by the bind.";
            };

            lua = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Inline Lua expression used by the Hyprland bind.";
            };

            flags = lib.mkOption {
              type = lib.types.attrsOf lua.type;
              default = { };
              description = "Flags passed to the Hyprland bind.";
            };
          };

          config = {
            hyprland = {
              cmd = lib.mkMerge [
                (lib.mkIf (config.cmd != null) (lib.mkDerivedConfig options.cmd lib.id))
                (lib.mkIf (config.app != null) (lib.mkDerivedConfig options.app (app: "uwsm app -- ${app}")))
              ];
              dsp = lib.mkIf (config.hyprland.cmd != null) (
                lib.mkDerivedConfig options.hyprland.cmd (cmd: {
                  exec_cmd = cmd;
                })
              );
              lua = lib.mkIf (config.hyprland.dsp != null) (lib.mkDerivedConfig options.hyprland.dsp renderDsp);
            };
          };
        }
      );

      enabledBinds = lib.filterAttrs (
        _: bind: bind.hyprland.enable && bind.hyprland.lua != null
      ) config.binds;

      renderArgs =
        params:
        if lib.isAttrs params && params ? _args then
          lib.concatMapStringsSep ", " toLua params._args
        else if params == null || params == { } then
          ""
        else
          toLua params;

      renderDsp =
        dsp:
        let
          dispatcher = dispatcherOf dsp;
          name = lib.head (lib.attrNames dispatcher);
        in
        "hl.dsp.${name}(${renderArgs dispatcher.${name}})";

      renderBind =
        keys: bind:
        let
          cfg = bind.hyprland;
          flags =
            cfg.flags
            // lib.optionalAttrs cfg.locked { locked = true; }
            // lib.optionalAttrs cfg.repeating { repeating = true; };
        in
        {
          _args = [
            keys
            (lua.lib.mkRaw cfg.lua)
          ]
          ++ lib.optional (flags != { }) flags;
        };
    in
    {
      options.binds = lib.mkOption {
        type = lib.types.attrsOf bindType;
      };

      config = {
        wayland.windowManager.hyprland.settings.bind = lib.mapAttrsToList renderBind enabledBinds;
      };
    };
}
