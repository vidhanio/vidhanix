{ inputs, ... }:
{
  hosts.vortex = {
    homeModule =
      { config, ... }:
      {
        imports = [ inputs.vane.homeManagerModules.default ];

        sops.secrets = {
          "vane/discord-token" = { };
          opencode = { };
        };

        sops.templates."vane-env".content = ''
          DISCORD_TOKEN=${config.sops.placeholder."vane/discord-token"}
          OPENCODE_API_KEY=${config.sops.placeholder.opencode}
        '';

        services.vane = {
          enable = true;
          environmentFile = config.sops.templates."vane-env".path;
          settings = {
            platforms.discord = {
              token = "\${DISCORD_TOKEN}";
              allowed_user_ids = [ "1063329635569512520" ];
            };

            agent = {
              provider = "opencode-go";
              model_id = "deepseek-v4.1-flash";
              thinking = "high";
              cwd = "~/Projects";
            };
          };
        };

        persist.directories = [ ".local/state/vane" ];
      };
  };
}
