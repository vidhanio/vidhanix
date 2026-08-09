{
  inputs,
  ...
}:
{
  flake-file.inputs.mattpocock-skills = {
    url = "github:mattpocock/skills";
    flake = false;
  };

  flake.modules.homeManager.default = _: {
    programs.agents.skills = {
      enable = true;

      skills.mattpocock = inputs.mattpocock-skills + "/skills";
    };
  };
}
