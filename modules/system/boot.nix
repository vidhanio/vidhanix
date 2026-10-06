{ lib, ... }:
{
  profiles.base.module =
    { pkgs, ... }:
    {
      boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            enable = true;
            consoleMode = "max";
          };
        };
        binfmt.emulatedSystems = lib.filter (system: system != pkgs.stdenv.hostPlatform.system) [
          "aarch64-linux"
          "x86_64-linux"
        ];
      };
    };
}
