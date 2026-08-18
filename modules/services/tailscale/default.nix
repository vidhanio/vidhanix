{
  flake.aspects.tailscale = {
    nixos =
      { config, ... }:
      {
        sops.secrets.tailscale = { };

        services.tailscale = {
          enable = true;
          authKeyFile = config.sops.secrets.tailscale.path;
          useRoutingFeatures = "both";
          extraSetFlags = [
            "--operator=${config.users.primaryUser}"
            "--ssh"
          ];
          extraUpFlags = [ "--reset" ] ++ config.services.tailscale.extraSetFlags;
        };

        networking = {
          nftables.enable = true;
          firewall = {
            trustedInterfaces = [ config.services.tailscale.interfaceName ];
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
      services.tailscale-systray = {
        enable = true;
        theme = "dark:nobg";
      };
    };
    provides.exit-node.nixos = {
      services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];
    };
  };
}
