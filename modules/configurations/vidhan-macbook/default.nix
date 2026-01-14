{ config, ... }:
{
  configurations.vidhan-macbook.module = {
    imports = with config.flake.modules.nixos; [ macbook ];
    nixpkgs.hostPlatform = "aarch64-linux";
    system.stateVersion = "26.05";
  };
}
