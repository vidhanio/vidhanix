{
  flake.modules = {
    nixos.default =
      { config, ... }:
      {
        age.secrets.tailscale.file = ../../secrets/tailscale.age;

        services.tailscale = {
          enable = true;
          authKeyFile = config.age.secrets.tailscale.path;
          useRoutingFeatures = "both";
          extraSetFlags = [
            "--advertise-exit-node"
            "--operator=vidhanio"
            "--ssh"
          ];
          extraUpFlags = config.services.tailscale.extraSetFlags;
        };

        networking = {
          nftables.enable = true;
          firewall = {
            trustedInterfaces = [ "tailscale0" ];
            allowedUDPPorts = [ config.services.tailscale.port ];
          };
        };

        systemd.services.tailscaled.serviceConfig.Environment = [
          "TS_DEBUG_FIREWALL_MODE=nftables"
        ];

        systemd.network.wait-online.enable = false;
        boot.initrd.systemd.network.wait-online.enable = false;

        persist.directories = [ "/var/lib/tailscale" ];
      };
    homeManager.default = {
      services.tailscale-systray.enable = true;
    };
  };
}
