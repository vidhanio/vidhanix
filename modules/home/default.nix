{ lib, inputs, ... }:
{
  home-manager.sharedModules =
    with inputs;
    [
      impermanence.homeManagerModules.default
      agenix.homeManagerModules.default
      ../../users/shared.nix
    ]
    ++ lib.readSubmodules ./.;
}
