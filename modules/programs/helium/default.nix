{ withSystem, ... }:
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
        "SUPER, B, exec, uwsm app -- helium"
      ];

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
