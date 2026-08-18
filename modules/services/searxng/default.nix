{
  # Local SearXNG instance for the machine's agents (omp search provider).
  # Reachable from the tailnet at http://vidhan-pc:8080.
  flake.aspects.searxng = {
    nixos =
      { config, ... }:
      {
        sops.secrets."searxng/secret-key" = { };

        sops.templates."searxng-env" = {
          owner = "searx";
          group = "searx";
          mode = "0400";
          content = ''
            SEARXNG_SECRET_KEY=${config.sops.placeholder."searxng/secret-key"}
          '';
        };

        services.searx = {
          enable = true;
          environmentFile = config.sops.templates."searxng-env".path;

          settings = {
            server = {
              secret_key = "$SEARXNG_SECRET_KEY";
              bind_address = "0.0.0.0";
              port = 8080;
              limiter = false;
              public_instance = false;
            };

            # The default is html-only; the json format powers the agents' API.
            search.formats = [
              "html"
              "json"
            ];
          };
        };
      };
  };
}
