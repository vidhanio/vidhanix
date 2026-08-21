{
  flake-file.inputs.helium.url = "github:schembriaiden/helium-browser-nix-flake";

  flake.aspects.helium = {
    homeManager =
      { inputs', pkgs, ... }:
      let
        lua = pkgs.formats.lua { };
        pkg = inputs'.helium.packages.default;
      in
      {
        home.packages = [ pkg ];

        xdg.autostart.entries = [ "${pkg}/share/applications/helium.desktop" ];

        wayland.windowManager.hyprland = {
          autostartWorkspaces.helium = 1;

          binds = {
            "SUPER + B" = lua.lib.mkRaw ''
              function()
                local window = hl.get_window("class:helium")
                if window then
                  hl.dispatch(hl.dsp.focus({ window = window }))
                else
                  hl.exec_cmd("uwsm app -- helium")
                end
              end
            '';
            "SUPER + SHIFT + B".exec_cmd = "uwsm app -- helium --new-window";
          };
        };

        persist.directories = [ ".config/net.imput.helium" ];
      };
  };
}
