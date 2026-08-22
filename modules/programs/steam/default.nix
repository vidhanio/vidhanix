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

    provides.apple-silicon.homeManager =
      { lib, pkgs, ... }:
      {
        # muvm guests can't reach the host session bus (no D-Bus transport
        # over virtiofs), which is why Steam's tray icon fails to register.
        # Expose the bus on loopback TCP; passt forwards guest traffic to the
        # host's default gateway onto loopback. Port must match
        # muvm-steam's dbusBridgePort.
        systemd.user.services.muvm-dbus-bridge = {
          Unit = {
            Description = "bridge the D-Bus session bus to muvm guests";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${lib.getExe pkgs.socat} TCP-LISTEN:49001,bind=127.0.0.1,reuseaddr,fork UNIX-CONNECT:%t/bus";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };

    provides.apple-silicon.nixos =
      { self', ... }:
      {
        programs.steam.package = self'.packages.muvm-steam;
        # steam asserts 32-bit graphics on x86; the guest gets them from muvm-steam.
        hardware.graphics.enable32Bit = lib.mkForce false;
      };
  };
}
