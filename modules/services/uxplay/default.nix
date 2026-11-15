{
  profiles.pc = {
    module =
      { config, ... }:
      {
        services.uxplay = {
          enable = true;
          openFirewall = true;
          settings = {
            n = config.networking.hostName;
            nh = true;
            p = 7100;
            vs = "waylandsink";
            scrsv = 1;
            key = true;
          };
        };
      };

    homeModule.persist.files = [ ".uxplay.pem" ];
  };
}
