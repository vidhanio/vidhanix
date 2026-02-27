{ config, ... }:
{
  configurations.vidhan-pc = {
    users.vidhanio = {
      enable = true;
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxMGko3NUtTtMB7pfDE1VYnTy1OR1fsLaGpVp9FaKtv vidhanio@vidhan-pc";
    };
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfS/WsqGHJYgJFWe+bf1SSKjyvFP0pISi30W/cvar/D root@vidhan-pc";
    module = {
      imports = with config.flake.modules.nixos; [ desktop ];
      hardware.facter.reportPath = ./facter.json;
      system.stateVersion = "26.05";
    };
  };
}
