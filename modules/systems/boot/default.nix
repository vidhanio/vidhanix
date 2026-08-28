{ lib, ... }:
{
  flake.aspects.boot = {
    _.desktop = {
      nixos =
        { pkgs, ... }:
        {
          boot.loader.efi.canTouchEfiVariables = true;
          boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        };
    };
  };
}
