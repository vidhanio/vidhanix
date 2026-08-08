{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.hermes = {
        enable = true;
        package = inputs'.llm-agents.packages.hermes-agent;

        settings = {
          model = "opencode-go/deepseek-v4-flash";
          agent.reasoning_effort = "max";
        };
      };

      persist.directories = [ ".hermes" ];
    };
}
