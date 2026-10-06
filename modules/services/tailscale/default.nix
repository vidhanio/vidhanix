{
  profiles.base.module =
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

  profiles.pc.homeModule =
    { lib, config, ... }:
    let
      inherit (config.stylix) polarity;
    in
    {
      services.tailscale-systray = {
        enable = true;
        theme = lib.mkIf (polarity != "either") "${polarity}:nobg";
      };
    };

  hosts.vortex.module.services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];
}
