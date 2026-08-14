_: {
  # This machine's wiring: opencode-go (deepseek-v4-flash) as the LLM via the
  # `opencode` sops secret. Storage comes from modules/services/hindsight.nix.
  configurations.vidhan-pc.homeModule =
    { config, ... }:
    {
      sops.secrets.opencode = { };

      sops.templates."hindsight-env" = {
        content = ''
          HINDSIGHT_API_LLM_API_KEY=${config.sops.placeholder.opencode}
        '';
      };

      programs.ai.hindsight = {
        enable = true;

        # Reachable from the tailnet as `vidhan-pc`; trustedInterfaces in
        # modules/services/tailscale.nix keeps the firewall out of the way.
        host = "0.0.0.0";

        database.url = "postgresql:///hindsight?host=/run/postgresql";

        llm = {
          provider = "opencode-go";
          model = "deepseek-v4-flash";
        };

        service.environmentFiles = [ config.sops.templates."hindsight-env".path ];
      };
    };
}
