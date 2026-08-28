{ lib, ... }:
{
  flake.aspects.hyprland = {
    homeManager =
      { config, pkgs, ... }:
      let
        binds = config.wayland.windowManager.hyprland.binds;
        autostartWorkspaces = config.wayland.windowManager.hyprland.autostartWorkspaces;

        lua = pkgs.formats.lua { };
        toLua = lib.generators.toLua { multiline = false; };

        # `_flags` is hl.bind's optional third argument; raw binds are complete Lua dispatchers.
        dispatcherOf = bind: lib.removeAttrs bind [ "_flags" ];

        bindType = lib.types.oneOf [
          lib.types.luaInline
          (
            lib.types.addCheck (lib.types.attrsOf lua.type) (
              bind: lib.length (lib.attrNames (dispatcherOf bind)) == 1
            )
            // {
              description = "Hyprland bind naming exactly one dispatcher";
              descriptionClass = "noun";
            }
          )
        ];

        # bare value = one argument, `{ }` = none, `_args` = list spread (HM's hyprland convention).
        renderArgs =
          params:
          if lib.isAttrs params && params ? _args then
            lib.concatMapStringsSep ", " toLua params._args
          else if params == null || params == { } then
            ""
          else
            toLua params;

        renderBind =
          keys: bind:
          let
            isRaw = (bind._type or null) == "lua-inline";
            dispatcher = dispatcherOf bind;
          in
          {
            _args = [
              keys
              (
                if isRaw then
                  bind
                else
                  let
                    name = lib.head (lib.attrNames dispatcher);
                  in
                  lua.lib.mkRaw "hl.dsp.${name}(${renderArgs dispatcher.${name}})"
              )
            ]
            ++ lib.optional (bind ? _flags) (lua.lib.mkRaw (toLua bind._flags));
          };
      in
      {
        options = {
          wayland.windowManager.hyprland = {
            binds = lib.mkOption {
              type = lib.types.attrsOf bindType;
              default = { };
              description = ''
                Hyprland keybinds, keyed by key combination.

                Each bind is either a raw Lua dispatcher expression or an attribute
                set naming exactly one `hl.dsp` dispatcher, whose value becomes its
                arguments. Nested dispatchers are written as dotted names, e.g.
                `"window.close"`. `{ }` calls the dispatcher with no arguments, an
                `_args` list spreads into multiple arguments, and any other value is
                passed as a single argument.

                The optional `_flags` attribute becomes the bind flag table passed as
                `hl.bind`'s third argument.
              '';
              example = lib.literalExpression ''
                {
                  "SUPER + 1".focus = {
                    workspace = 1;
                    on_current_monitor = true;
                  };

                  "SUPER + Q"."window.close" = { };

                  "SUPER + RETURN".exec_cmd = "ghostty";

                  "SUPER + mouse:272" = {
                    "window.drag" = { };
                    _flags.mouse = true;
                  };
                }
              '';
            };
            autostartWorkspaces = lib.mkOption {
              type = lib.types.attrsOf lib.types.ints.positive;
              default = { };
              description = ''
                Map Hyprland window classes to temporary startup workspace assignments.
              '';
            };
          };
        };

        config = {
          wayland.windowManager.hyprland = {
            settings.bind = lib.mapAttrsToList renderBind binds;

            extraConfig = lib.mkIf (autostartWorkspaces != { }) ''
              local autostartWorkspaceRules = {}

              ${lib.concatStringsSep "\n" (
                lib.mapAttrsToList (class: workspace: ''
                  autostartWorkspaceRules[#autostartWorkspaceRules + 1] = hl.window_rule({
                    match = { class = "${class}" },
                    workspace = "${toString workspace} silent",
                  })
                '') autostartWorkspaces
              )}
              -- Only redirect each app's startup launch; let later manual launches behave normally.
              hl.timer(function()
                for _, rule in ipairs(autostartWorkspaceRules) do
                  rule:set_enabled(false)
                end
              end, { timeout = 10000, type = "oneshot" })
            '';
          };
        };
      };
  };
}
