{
  flake.modules.homeManager.default = { inputs', ... }: {
    programs.bb = {
      enable = true;

      package = inputs'.llm-agents.packages.bb-app;

      # Helper inference through the opencode CLI on PATH, like the other
      # harnesses' opencode-go default. The fallback mirrors the primary model
      # because deepseek-v4-flash is the only one configured here.
      settings.config = {
        BB_INFERENCE = "acp-opencode/deepseek-v4-flash";
        BB_INFERENCE_FALLBACK = "acp-opencode/deepseek-v4-flash";
      };
    };

    persist.directories = [ ".bb" ];
  };
}
