{
  flake.aspects.omp.homeManager = { inputs', ... }: {
    programs.omp = {
      enable = true;
      enableMcpIntegration = true;
      package = inputs'.llm-agents.packages.omp;

      settings = {
        startup = {
          setupWizard = false;
        };

        # The local SearXNG instance (modules/services/searxng.nix) as the
        # web search provider, reachable from the tailnet.
        providers.webSearchOrder = [ "searxng" ];
        searxng.endpoint = "http://vidhan-pc:8080";

        symbolPreset = "nerd";

        modelRoles.default = "opencode-go/deepseek-v4-flash:max";
      };

      # TODO: https://github.com/can1357/oh-my-pi/pull/8064
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
}
