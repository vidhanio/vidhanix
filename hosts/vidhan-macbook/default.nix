{
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.apple-silicon.nixosModules.default ] ++ lib.readSubmodules ./.;

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "26.05";
}
