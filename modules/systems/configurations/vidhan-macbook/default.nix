{ config, ... }:
{
  configurations.vidhan-macbook = {
    users.vidhanio = {
      enable = true;
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpEHUbyfwBLGJqsrZLO8xDpldmg655DPYLGNOJUJfHM vidhanio@vidhan-macbook";
    };
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrlsMqmLKW+8+MyHndMWNZXk86Oo0Ik8wPs3v1Nx7ZR root@vidhan-macbook";
    module = {
      imports = with config.flake.modules.nixos; [ macbook ];
      hardware.monitors.main = {
        name = "eDP-1";
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.6;
      };
      nixpkgs.hostPlatform = "aarch64-linux";
      system.stateVersion = "26.05";
    };
  };
}
