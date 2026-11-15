{
  profiles.pc = {
    module =
      { config, ... }:
      let
        inherit (config.users.users.${config.users.primaryUser}) home;
      in
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
            key = "${home}/.local/state/uxplay/key.pem";
          };
        };
      };

    homeModule.persist.directories = [ ".local/state/uxplay" ];
  };
}
