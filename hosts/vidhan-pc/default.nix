{
  lib,
  pkgs,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  services.openssh = {
    enable = true;
  };

  services.usbmuxd.enable = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";
}
