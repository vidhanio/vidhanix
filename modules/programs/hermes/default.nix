{ inputs, ... }:
{
  flake-file.inputs.hermes.url = "github:NousResearch/hermes-agent";

  flake.aspects.hermes = {
    homeManager =
      { ... }:
      {
        imports = [ inputs.hermes.homeManagerModules.default ];

        programs.hermes-agent.desktop.enable = true;
      };
  };
}
