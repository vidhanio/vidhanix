{ lib, ... }:
{
  profiles.pc.homeModule =
    { pkgs, ... }:
    {
      services.flatpak.packages = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 [
        "org.vinegarhq.Sober"
      ];
    };
}
