{ lib, ... }:
{
  profiles.pc.homeModule =
    { pkgs, self', ... }:
    {
      programs.steam.config.apps."322170" = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        name = "Geometry Dash";
        env = {
          PROTON_USE_NTSYNC = "1";
          vblank_mode = "0";
          LD_PRELOAD = "${lib.getLib pkgs.pkgsi686Linux.libevdev}/lib/libevdev.so";
        };
        dllOverrides.xinput1_4 = "n,b";

        files.game = {
          place = lib.genAttrs [ "Geode.dll" "XInput1_4.dll" "GeodeUpdater.exe" ] (name: {
            source = "${self'.packages.geode}/${name}";
          });
          remove = [ "XINPUT1_4.dll" ];
        };
      };
    };
}
