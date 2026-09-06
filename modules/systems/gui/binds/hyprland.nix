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

      dispatcherOf = dsp: lib.removeAttrs dsp [ "_flags" ];

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

            exec = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = if config.app != null then "uwsm app -- ${config.app}" else config.exec;
              defaultText = lib.literalExpression ''if config.app != null then "uwsm app -- ''${config.app}" else config.exec'';
              description = "Command run by the Hyprland bind.";
            };

            dsp = lib.mkOption {
              type = lib.types.nullOr dspType;
              description = ''
                Hyprland dispatcher called by the bind. The optional `_flags`
                attribute is passed to `hl.bind` as its flag table.
              '';
            };

            luaRaw = lib.mkOption {
              type = lib.types.nullOr lib.types.luaInline;
              description = "Raw Lua dispatcher expression used by the Hyprland bind.";
            };
          };

          config = {
            hyprland.dsp = lib.mkDerivedConfig options.hyprland.exec (
              exec: if exec == null then null else { exec_cmd = exec; }
            );
            hyprland.luaRaw = lib.mkDerivedConfig options.hyprland.dsp (
              dsp: if dsp == null then null else renderDsp dsp
            );
          };
        }
      );

      enabledBinds = lib.filterAttrs (_: bind: bind.hyprland.enable) config.binds;

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
        lua.lib.mkRaw "hl.dsp.${name}(${renderArgs dispatcher.${name}})";

      renderBind =
        keys: bind:
        let
          cfg = bind.hyprland;
          flags =
            lib.removeAttrs (if cfg.dsp != null && cfg.dsp ? _flags then cfg.dsp._flags else { }) [
              "locked"
              "repeating"
            ]
            // lib.optionalAttrs cfg.locked { locked = true; }
            // lib.optionalAttrs cfg.repeating { repeating = true; };
        in
        {
          _args = [
            keys
            cfg.luaRaw
          ]
          ++ lib.optional (flags != { }) (lua.lib.mkRaw (toLua flags));
        };
    in
    {
      options.binds = lib.mkOption {
        type = lib.types.attrsOf bindType;
      };

      config = {
        assertions = lib.mapAttrsToList (keys: bind: {
          assertion = !bind.hyprland.enable || bind.hyprland.luaRaw != null;
          message = "binds.${lib.escapeNixIdentifier keys}.hyprland must resolve to raw Lua";
        }) config.binds;

        wayland.windowManager.hyprland.settings.bind = lib.mapAttrsToList renderBind enabledBinds;
      };
    };
}
