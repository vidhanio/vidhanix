{ lib, ... }:
{
  flake.aspects.boot.provides.desktop.nixos =
    { pkgs, ... }:
    {
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
}
