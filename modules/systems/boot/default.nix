{ lib, ... }:
{
  profiles.base = {
    module = { pkgs, ... }: {
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
  };
}
