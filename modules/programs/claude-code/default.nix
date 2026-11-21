{
  profiles.pc = {
    homeModule =
      { config, inputs', ... }:
      let
        inherit (inputs'.llm-agents) packages;
      in
      {
        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;
          package = packages.claude-code;
          context = config.agents.context;
          settings = {
            permissions.defaultMode = "auto";
            attribution = {
              commit = "";
              pr = "";
              sessionUrl = false;
            };
            autoMemoryEnabled = false;
            feedbackSurveyRate = 0;
            spinnerTipsEnabled = false;
          };
        };

        home.packages = [
          (packages.claude-agent-acp.override { claude-code = config.programs.claude-code.finalPackage; })
        ];

        persist.directories = [ ".claude" ];
      };
  };
}
