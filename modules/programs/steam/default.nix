{ lib, ... }:
{
  flake.aspects.steam = {
    nixos = {
      hardware.steam-hardware.enable = true;
      programs.steam.enable = true;
    };

    homeManager =
      { osConfig, ... }:
      {
        persist.directories = [ ".local/share/Steam" ];
        xdg.autostart.entries = lib.mkIf (osConfig.networking.hostName == "vortex") [
          "${osConfig.programs.steam.package}/share/applications/steam.desktop"
        ];
        wayland.windowManager.hyprland.autostartWorkspaces.steam = lib.mkIf (
          osConfig.networking.hostName == "vortex"
        ) 3;
      };

    _.apple-silicon.nixos =
      { self', ... }:
      {
        programs.steam.package = self'.packages.muvm-steam;
        # steam asserts 32-bit graphics on x86; the guest gets them from muvm-steam.
        hardware.graphics.enable32Bit = lib.mkForce false;
      };
  };
}
