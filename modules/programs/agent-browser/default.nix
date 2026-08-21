{
  flake.aspects.agent-browser = {
    homeManager =
      { inputs', ... }:
      let
        pkg = inputs'.llm-agents.packages.agent-browser;
      in
      {
        home.packages = [ pkg ];

        programs.agents.skills.skills.agent-browser = "${pkg.src}/skills/agent-browser";
      };
  };
}
