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

          providers.webSearchOrder = [ "searxng" ];
          searxng.endpoint = "http://vortex:8080";

          symbolPreset = "nerd";
        };
      };

      persist.directories = [ ".omp" ];
    };
  };
}
