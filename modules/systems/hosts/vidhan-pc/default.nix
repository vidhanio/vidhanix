{ inputs, ... }:
{
  flake.aspects =
    { aspects, ... }:
    {
      vidhan-pc = {
        includes = [
          aspects.desktop
          aspects.disk.provides.desktop
          aspects.boot.provides.desktop
          aspects.searxng
          aspects.tailscale.provides.exit-node
        ];
        nixos =
          { inputs', ... }:
          {
            networking.hostName = "vidhan-pc";
            nixpkgs.hostPlatform = "x86_64-linux";
            disko.devices.disk.main.device = "/dev/disk/by-id/nvme-SHPP41-2000GM_ASDAN54031240AV5V";
            hardware.monitors = {
              main = {
                name = "DP-1";
                mode = {
                  width = 2560;
                  height = 1440;
                  refreshRate = 300.002014;
                };
                position = {
                  x = 0;
                  y = 1080;
                };
                scale = 1.0;
              };
              others = [
                {
                  name = "HDMI-A-1";
                  mode = {
                    width = 2560;
                    height = 1080;
                    refreshRate = 60.0;
                  };
                  position = {
                    x = 0;
                    y = 0;
                  };
                  scale = 1.0;
                }
              ];
            };
            hardware.facter.reportPath = ./facter.json;
            system.stateVersion = "26.05";
            boot.loader.systemd-boot.windows."11".efiDeviceHandle = "HD0d";
            environment.shellAliases.reboot-windows = "systemctl reboot --boot-loader-entry windows_11.conf";
            boot.kernelPackages = inputs'.nix-cachyos-kernel.legacyPackages.linuxPackages-cachyos-latest;
          };
      };
    };

  flake-file = {
    inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nixConfig = {
      extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
      extra-trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];
    };
    prune-lock.ignore = [ "nix-cachyos-kernel" ];
  };

  configurations.vidhan-pc = {
    users.vidhanio = {
      enable = true;
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxMGko3NUtTtMB7pfDE1VYnTy1OR1fsLaGpVp9FaKtv vidhanio@vidhan-pc";
    };
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfS/WsqGHJYgJFWe+bf1SSKjyvFP0pISi30W/cvar/D root@vidhan-pc";
    module = inputs.self.modules.nixos.vidhan-pc;
  };
}
