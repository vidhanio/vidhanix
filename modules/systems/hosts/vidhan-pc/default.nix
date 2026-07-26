{ den, ... }:
{
  den.hosts.x86_64-linux.vidhan-pc = {
    primaryUser = "vidhanio";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfS/WsqGHJYgJFWe+bf1SSKjyvFP0pISi30W/cvar/D root@vidhan-pc";

    users.vidhanio.sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxMGko3NUtTtMB7pfDE1VYnTy1OR1fsLaGpVp9FaKtv vidhanio@vidhan-pc";
  };

  den.aspects.vidhan-pc = {
    includes = [ den.aspects.desktop ];

    nixos = {
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
    };
  };
}
