{ inputs, ... }:
{
  flake.aspects =
    { aspects, ... }:
    {
      vidhan-macbook = {
        includes = [ aspects.apple-silicon ];
        nixos = {
          networking.hostName = "vidhan-macbook";
          nixpkgs.hostPlatform = "aarch64-linux";
          disko.devices.disk.main = {
            device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0256Q_0ba012e404080419";
            content.partitions = {
              iBootSystemContainer.uuid = "62132ea7-731c-44eb-848a-80a899f51311";
              Container.uuid = "b45447e2-9e71-469e-9601-d4364bdfb492";
              NixOSContainer.uuid = "37fe6b82-8e1a-4271-9192-d267ce78602c";
              ESP.uuid = "42dd4099-5e91-4a89-9c26-f07119130d4a";
              RecoveryOSContainer.uuid = "37b1fd46-dc1b-4342-887c-f533d6ca1de2";
            };
          };
          hardware.monitors.main = {
            name = "eDP-1";
            position = {
              x = 0;
              y = 0;
            };
            scale = 1.6;
          };
          hardware.asahi.peripheralFirmwareDirectory = ./firmware;
          system.stateVersion = "26.05";
        };
      };
    };

  hosts.vidhan-macbook = {
    users.vidhanio = {
      enable = true;
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpEHUbyfwBLGJqsrZLO8xDpldmg655DPYLGNOJUJfHM vidhanio@vidhan-macbook";
    };
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrlsMqmLKW+8+MyHndMWNZXk86Oo0Ik8wPs3v1Nx7ZR root@vidhan-macbook";
    module = inputs.self.modules.nixos.vidhan-macbook;
  };
}
