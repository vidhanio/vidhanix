{
  flake.aspects.hermes.provides.gateway = {
    homeManager =
      {
        config,
        lib,
        ...
      }:
      let
        model = config.programs.agents.models.default;
      in
      {
        sops.secrets.opencode = { };

        sops.templates."hermes-auth".content = builtins.toJSON {
          version = 1;

          credential_pool."opencode-go" = [
            {
              id = "nix";
              label = "api-key-1";
              auth_type = "api_key";
              priority = 0;
              source = "manual";
              access_token = config.sops.placeholder.opencode;
              base_url = "https://opencode.ai/zen/go/v1";
              request_count = 0;
            }
          ];
        };

        programs.hermes-agent.enable = true;

        services.hermes-agent = {
          enable = true;

          authFile = config.sops.templates."hermes-auth".path;

          backend.mode = lib.mkDefault "dashboard";
          gateway.enable = true;

          settings = {
            display.interface = "tui";
            model.default = "${model.provider}/${model.model}";
            model.provider = model.provider;
            agent.reasoning_effort = model.thinking;
          };
        };

        persist.directories = [ ".hermes" ];
      };
  };
}
