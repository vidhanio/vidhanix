{
  withSystem,
  ...
}:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = withSystem pkgs.stdenv.hostPlatform.system (
        { self', ... }: [ self'.packages.helium-bin ]
      );

      wayland.windowManager.hyprland.settings.bind = [
        "SUPER, B, exec, uwsm app -- helium"
      ];

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
