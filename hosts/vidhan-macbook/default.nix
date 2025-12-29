{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.default
  ]
  ++ lib.readImportsRecursively ./.;

  nixpkgs.hostPlatform = "aarch64-linux";

  system.stateVersion = "26.05";
}
