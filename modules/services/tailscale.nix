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
          ];
          extraUpFlags = config.services.tailscale.extraSetFlags;
        };

        persist.directories = [ "/var/lib/tailscale" ];
      };
    homeManager.default = {
      services.tailscale-systray.enable = true;
    };
  };
}
