{ inputs, lib, ... }:
let
  extraEnv = {
    SDL_VIDEODRIVER = "wayland";
    SDL_VIDEO_DRIVER = "wayland";
    PROTON_ENABLE_WAYLAND = "1";
  };
in
{
  profiles.pc = {
    module =
      { pkgs, ... }:
      {
        programs.steam = {
          enable = true;
          package = lib.mkDefault (pkgs.steam.override { inherit extraEnv; });
          extraCompatPackages = [ pkgs.proton-ge-bin ];
        };
        hardware.steam-hardware.enable = true;
      };

    homeModule =
      { osConfig, pkgs, ... }:
      {
        imports = [ inputs.steam-config-nix.homeModules.default ];

        programs.steam.config = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
          enable = true;
          defaultCompatTool = pkgs.proton-ge-bin;
          apps = {
            "730" = {
              name = "Counter-Strike 2";
              args = [
                "-w"
                "1920"
                "-h"
                "1440"
              ];
            };
            "440" = {
              name = "Team Fortress 2";
              args = [
                "-novid"
                "-nohltv"
                "-particles"
                "1"
                "-nostartupsound"
                "-fullscreen"
              ];
            };
            "322170" = {
              name = "Geometry Dash";
              env = {
                PROTON_USE_NTSYNC = "1";
                vblank_mode = "0";
                LD_PRELOAD = "${lib.getLib pkgs.pkgsi686Linux.libevdev}/lib/libevdev.so";
              };
              dllOverrides.xinput1_4 = "n,b";
            };
          };
        };

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
      programs.steam.package = self'.packages.muvm-steam.override { inherit extraEnv; };
      # Steam asserts 32-bit graphics on x86; the guest gets them from `muvm-steam`.
      hardware.graphics.enable32Bit = lib.mkForce false;
    };
}
