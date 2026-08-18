{
  flake.aspects.prime-agent = {
    homeManager =
      { inputs', ... }:
      let
        pkg = inputs'.llm-agents.packages.prime-agent;
      in
      {
        programs.prime-agent = {
          enable = true;
          enableMcpIntegration = true;

          package = pkg;

          settings = {
            defaultProvider = "opencode-go";
            defaultModel = "deepseek-v4-flash";
            rlmMaxDepth = 2;
            defaultThinkingLevel = "max";
          };
        };

        persist.directories = [ ".prime/agent" ];
      };
  };
}
