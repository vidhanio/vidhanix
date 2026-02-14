{ config, ... }:
{
  configurations.vidhan-macbook = {
    users = [ "vidhanio" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrlsMqmLKW+8+MyHndMWNZXk86Oo0Ik8wPs3v1Nx7ZR root@vidhan-macbook";
    module = {
      imports = with config.flake.modules.nixos; [ macbook ];
      nixpkgs.hostPlatform = "aarch64-linux";
      system.stateVersion = "26.05";
    };
  };
}
