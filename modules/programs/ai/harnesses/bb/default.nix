{
  flake.modules.homeManager.default = { inputs', ... }: {
    programs.bb = {
      enable = true;

      package = inputs'.llm-agents.packages.bb-app;

      # Helper inference rides the pi stack: pi-ai's opencode-go route with
      # the model pi defaults to (see the pi-coding-agent module), so bb's
      # server-side helpers use the same model as the `pi` thread provider.
      settings.config = {
        BB_INFERENCE = "opencode-go/deepseek-v4-flash";
        BB_INFERENCE_FALLBACK = "opencode-go/deepseek-v4-flash";
      };
    };

    persist.directories = [ ".bb" ];
  };
}
