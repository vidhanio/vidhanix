{
  flake.modules.nixos.default =
    { config, ... }:
    {
      age.secrets.tailscale.file = ../../secrets/tailscale.age;

      services.tailscale = {
        enable = true;
        authKeyFile = config.age.secrets.tailscale.path;
        useRoutingFeatures = "both";
        extraUpFlags = [ "--advertise-exit-node" ];
      };

      persist.directories = [ "/var/lib/tailscale" ];
    };
}
