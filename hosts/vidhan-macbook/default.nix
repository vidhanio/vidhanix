{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  hardware.graphics.package =
    # Workaround for Mesa 25.3.0 regression
    # https://github.com/nix-community/nixos-apple-silicon/issues/380
    assert pkgs.mesa.version == "25.3.1";
    (import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/c5ae371f1a6a7fd27823bc500d9390b38c05fa55.tar.gz";
      sha256 = "sha256-4PqRErxfe+2toFJFgcRKZ0UI9NSIOJa+7RXVtBhy4KE=";
    }) { localSystem = pkgs.stdenv.hostPlatform; }).mesa;

  system.stateVersion = "26.05";
}
