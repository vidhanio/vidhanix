{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      boot = {
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_latest;
      };
    };
}
