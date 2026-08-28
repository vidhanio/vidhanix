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
    homeManager =
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

    _.exit-node.nixos = {
      services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];
    };
  };
}
