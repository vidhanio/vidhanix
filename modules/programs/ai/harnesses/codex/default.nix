{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.codex = {
        enable = true;
        enableMcpIntegration = true;

        package = inputs'.llm-agents.packages.codex;

        settings = {
          model = "deepseek-v4-flash";
          model_provider = "opencode-go";

          model_providers.opencode-go = {
            name = "OpenCode Go";
            base_url = "https://opencode.ai/zen/go/v1";
            env_key = "OPENCODE_API_KEY";
            requires_openai_auth = false;
          };

          model_reasoning_effort = "max";
        };
      };

      persist.directories = [ ".codex" ];
    };
}
