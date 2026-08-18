{
  flake.aspects.omp = {
    homeManager = { inputs', ... }: {
      programs.omp = {
        enable = true;
        enableMcpIntegration = true;
        package = inputs'.llm-agents.packages.omp;

        settings = {
          startup = {
            setupWizard = false;
          };

          # the local SearXNG instance (modules/services/searxng/default.nix) as
          # the web search provider, reachable from the tailnet.
          providers.webSearchOrder = [ "searxng" ];
          searxng.endpoint = "http://vortex:8080";

          symbolPreset = "nerd";

          modelRoles.default = "opencode-go/deepseek-v4-flash:max";
        };

        # todo: https://github.com/can1357/oh-my-pi/pull/8064
        models.providers.opencode-go.modelOverrides.deepseek-v4-flash = {
          thinking = {
            mode = "effort";
            efforts = [
              "low"
              "high"
              "max"
            ];
          };
        };
      };

      persist.directories = [ ".omp" ];
    };
  };
}
