{
  flake.aspects.cachix = {
    nixos =
      { config, ... }:
      {
        sops.secrets.cachix = { };

        services.cachix-watch-store = {
          enable = true;
          cacheName = "vidhanio";
          cachixTokenFile = config.sops.secrets.cachix.path;
        };
      };
  };
}
