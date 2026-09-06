{

  flake.aspects.helium.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      lua = pkgs.formats.lua { };
      cfg = config.programs.helium;
    in
    {
      programs.helium.enable = true;

      xdg.autostart.entries = lib.mkIf (cfg.finalPackage != null) [
        "${cfg.finalPackage}/share/applications/helium.desktop"
      ];

      wayland.windowManager.hyprland.autostartWorkspaces.helium = 1;

      binds = {
        "SUPER + B".hyprland.luaRaw = lua.lib.mkRaw ''
          function()
            local window = hl.get_window("class:helium")
            if window then
              hl.dispatch(hl.dsp.focus({ window = window }))
            else
              hl.exec_cmd("uwsm app -- helium")
            end
          end
        '';
        "SUPER + SHIFT + B".app = "helium --new-window";
      };

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
