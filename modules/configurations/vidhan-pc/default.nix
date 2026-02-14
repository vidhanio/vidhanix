{ config, ... }:
{
  configurations.vidhan-pc = {
    users = [ "vidhanio" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfS/WsqGHJYgJFWe+bf1SSKjyvFP0pISi30W/cvar/D root@vidhan-pc";
    module = {
      imports = with config.flake.modules.nixos; [ desktop ];
      hardware.facter.reportPath = ./facter.json;
      system.stateVersion = "26.05";
    };
  };
}
