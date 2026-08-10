{
  flake.modules.homeManager.default =
    { self', ... }:
    {
      home.packages = [
        self'.packages.fluxcast
      ];

      hyprland.binds."SUPER + C".exec_cmd = "fluxcast --tray";

      persist.directories = [ ".config/fluxcast" ];
    };
}
