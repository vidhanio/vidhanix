{
  flake.modules.nixos.default = args: {
    age.secrets.tailscale.file = ../../secrets/tailscale.age;

    services.tailscale = {
      enable = true;
      authKeyFile = args.config.age.secrets.tailscale.path;
      useRoutingFeatures = "both";
      extraSetFlags = [ "--advertise-exit-node" ];
    };
  };
}
