{ lib, ... }:
{
  profiles.pc = {
    module = { pkgs, ... }: {
      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
      hardware.steam-hardware.enable = true;
    };

    homeModule =
      { osConfig, ... }:
      {
        persist.directories = [ ".local/share/Steam" ];
        desktop.workspaces.gaming.apps = [ "steam" ];
        xdg.autostart.entries = lib.mkIf (osConfig.networking.hostName == "vortex") [
          "${osConfig.programs.steam.package}/share/applications/steam.desktop"
        ];
      };

  };

  profiles.apple-silicon.module =
    { self', ... }:
    {
      programs.steam.package = self'.packages.muvm-steam;
      # steam asserts 32-bit graphics on x86; the guest gets them from muvm-steam.
      hardware.graphics.enable32Bit = lib.mkForce false;
    };
}
