{ lib, ... }:
{
  flake.modules = {
    nixos = {
      default = {
        hardware.steam-hardware.enable = true;

        programs.steam.enable = true;
      };

      macbook =
        { self', ... }:
        {
          programs.steam.package = self'.packages.muvm-steam.override { memoryMiB = 6144; };

          # `programs.steam` sets this unconditionally, but it asserts
          # `isx86_64`. the guest gets its 32-bit drivers from the
          # /run/opengl-driver-32 symlink muvm-steam makes instead.
          hardware.graphics.enable32Bit = lib.mkForce false;
        };
    };

    homeManager.default = {
      persist.directories = [ ".local/share/Steam" ];
    };
  };

  configurations.vidhan-pc.homeModule =
    { osConfig, ... }:
    {
      xdg.autostart.entries = [ "${osConfig.programs.steam.package}/share/applications/steam.desktop" ];

      hyprland.autostartWorkspaces.steam = 3;
    };
}
