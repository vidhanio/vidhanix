{
  profiles.pc = {
    homeModule =
      { inputs', ... }:
      {
        programs.antigravity-cli = {
          enable = true;
          enableMcpIntegration = true;
          package = inputs'.llm-agents.packages.antigravity-cli;
        };

        persist.directories = [ ".gemini/antigravity-cli" ];
      };
  };
}
