{ withSystem, lib, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    let
      pkg = withSystem pkgs.stdenv.hostPlatform.system ({ self', ... }: self'.packages.helium-bin);
    in
    {
      home.packages = [
        pkg
      ];

      xdg.autostart.entries = [ "${pkg}/share/applications/helium.desktop" ];

      hyprland.autostartWorkspaces.helium = 1;

      wayland.windowManager.hyprland.settings.bind = [
        {
          _args = [
            "SUPER + B"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("uwsm app -- helium")'')
          ];
        }
      ];

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
