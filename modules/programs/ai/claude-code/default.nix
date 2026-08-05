{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.claude-code = {
        enable = true;
        package = inputs'.llm-agents.packages.claude-code;
        rules = {
          karpathy-guidelines = ./rules/karpathy-guidelines.md;
        };
        outputStyles = {
          asd-ste100 = ./output-styles/asd-ste100.md;
        };
        settings = {
          permissions.defaultMode = "auto";
          attribution = {
            commit = "";
            pr = "";
            sessionUrl = false;
          };
          outputStyle = "ASD-STE100";
          autoMemoryEnabled = false;
          feedbackSurveyRate = 0;
          spinnerTipsEnabled = false;
        };
      };

      persist = {
        directories = [
          ".claude/projects"
          ".claude/sessions"
        ];
        files = [
          ".claude.json"
          ".claude/.credentials.json"
          ".claude/history.jsonl"
        ];
      };
    };
}
