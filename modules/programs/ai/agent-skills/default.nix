{ inputs, ... }:
{
  flake-file = {
    inputs.agent-skills.url = "github:Kyure-A/agent-skills-nix";

    inputs.mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
  };

  flake.modules.homeManager.default =
    { ... }:
    {
      imports = [ inputs.agent-skills.homeManagerModules.default ];

      programs.agent-skills = {
        enable = true;

        sources.mattpocock = {
          path = inputs.mattpocock-skills;
          subdir = "skills";
        };

        skills.enableAll = true;

        targets.agents.enable = true;
      };
    };
}
