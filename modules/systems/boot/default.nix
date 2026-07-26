{
  den.aspects.desktop.nixos =
    { pkgs, lib, ... }:
    {
      boot = {
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      };
    };
}
