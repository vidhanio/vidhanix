{
  den.default = {
    nixos =
      { config, host, ... }:
      {
        sops.secrets.tailscale = { };

        services.tailscale = {
          enable = true;
          authKeyFile = config.sops.secrets.tailscale.path;
          useRoutingFeatures = "both";
          extraSetFlags = [
            "--operator=${host.primaryUser}"
            "--ssh"
          ];
          extraUpFlags = [ "--reset" ] ++ config.services.tailscale.extraSetFlags;
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
    homeManager = {
      services.tailscale-systray.enable = true;
    };
  };
}
