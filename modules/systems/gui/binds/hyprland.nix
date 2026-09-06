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
        { config, ... }:
        {
          options.hyprland = {
            enable = lib.mkEnableOption "this bind for Hyprland" // {
              default = true;
            };

            exec = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = if config.app != null then "uwsm app -- ${config.app}" else config.exec;
              defaultText = lib.literalExpression ''if config.app != null then "uwsm app -- ''${config.app}" else config.exec'';
              description = "Command run by the Hyprland bind.";
            };

            dsp = lib.mkOption {
              type = lib.types.nullOr dspType;
              default = null;
              description = ''
                Hyprland dispatcher called by the bind. The optional `_flags`
                attribute is passed to `hl.bind` as its flag table.
              '';
            };

            luaRaw = lib.mkOption {
              type = lib.types.nullOr lib.types.luaInline;
              default = null;
              description = "Raw Lua dispatcher expression used by the Hyprland bind.";
            };
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
          action =
            if cfg.luaRaw != null then
              cfg.luaRaw
            else if cfg.dsp != null then
              renderDsp cfg.dsp
            else
              lua.lib.mkRaw "hl.dsp.exec_cmd(${toLua cfg.exec})";
        in
        {
          _args = [
            keys
            action
          ]
          ++ lib.optional (cfg.dsp != null && cfg.dsp ? _flags) (lua.lib.mkRaw (toLua cfg.dsp._flags));
        };
    in
    {
      options.binds = lib.mkOption {
        type = lib.types.attrsOf bindType;
      };

      config = {
        assertions = lib.mapAttrsToList (keys: bind: {
          assertion =
            !bind.hyprland.enable
            ||
              lib.count (action: action != null) [
                bind.hyprland.exec
                bind.hyprland.dsp
                bind.hyprland.luaRaw
              ] == 1;
          message = "binds.${lib.escapeNixIdentifier keys}.hyprland must define exactly one action";
        }) config.binds;

        wayland.windowManager.hyprland.settings.bind = lib.mapAttrsToList renderBind enabledBinds;
      };
    };
}
