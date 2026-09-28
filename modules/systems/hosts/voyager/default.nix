{
  flake.aspects =
    { aspects, ... }:
    {
      voyager = {
        includes = with aspects; [ apple-silicon ];
        nixos = {
          disko.devices.disk.main.device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0256Q_0ba0148a012cb231";
          hardware.monitors.main = {
            name = "eDP-1";
            position = {
              x = 0;
              y = 0;
            };
            scale = 1.6;
          };
          hardware.asahi.peripheralFirmwareDirectory = ./firmware;
        };
      };
    };

  hosts.voyager = {
    hostPlatform = "aarch64-linux";
    users.vidhanio = {
      enable = true;
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpEHUbyfwBLGJqsrZLO8xDpldmg655DPYLGNOJUJfHM vidhanio@voyager";
    };
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrlsMqmLKW+8+MyHndMWNZXk86Oo0Ik8wPs3v1Nx7ZR voyager";
  };
}
