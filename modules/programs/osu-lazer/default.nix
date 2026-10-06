{
  lib,
  ...
}:
{
  profiles.pc.homeModule =
    { pkgs, ... }:
    {
      # only distributed for x86_64; the source build has no score submission or multiplayer
      home.packages = lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
        (pkgs.osu-lazer-bin.override { nativeWayland = true; })
      ];

      persist.directories = [ ".local/share/osu" ];
    };
}
