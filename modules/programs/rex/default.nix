{ inputs, ... }:
{
  profiles.base = {
    module =
      { config, ... }:
      {
        users.users.${config.users.primaryUser}.linger = true;
      };

    homeModule =
      { osConfig, ... }:
      {
        imports = [ inputs.rex.homeManagerModules.default ];

        programs.ssh.enable = true;
        programs.rex.enable = true;
        services.rex = {
          enable = true;
          tailscale = {
            enable = true;
            hostname = "rex-${osConfig.networking.hostName}";
          };
        };

        persist.directories = [ ".local/state/rex" ];
      };
  };
}
