{ inputs, ... }:
{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.claude-code = {
        enable = true;
        package = inputs'.llm-agents.packages.claude-code;
        skills = {
          karpathy-guidelines = "${inputs.andrej-karpathy-skills}/skills/karpathy-guidelines";
        };
        settings = {
          permissions.defaultMode = "auto";
          attribution = {
            commit = "";
            pr = "";
            sessionUrl = false;
          };
        };
      };

      persist = {
        directories = [ ".claude" ];
        files = [ ".claude.json" ];
      };
    };
}
