{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.herdr = {
        enable = true;
        package = inputs'.llm-agents.packages.herdr;
      };
    };
}
