{ config, ... }:
{
  configurations.vidhan-pc.module = {
    imports = with config.flake.modules.nixos; [ pc ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "26.05";
  };
}
