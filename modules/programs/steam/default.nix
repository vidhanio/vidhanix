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
          package = lib.mkDefault (
            (if pkgs.stdenv.hostPlatform.isx86_64 then pkgs.steamWithMillennium else pkgs.steam).override {
              inherit extraEnv;
            }
          );
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
      programs.steam.package = self'.packages.muvm-steam.override {
        millenniumPackage = self'.packages.millennium-arm64;
        # muvm forwards X11, not the host Wayland socket.
        extraEnv = extraEnv // {
          SDL_VIDEODRIVER = "x11";
          SDL_VIDEO_DRIVER = "x11";
        };
      };
      # Steam asserts 32-bit graphics on x86; the guest gets them from `muvm-steam`.
      hardware.graphics.enable32Bit = lib.mkForce false;
    };
}
