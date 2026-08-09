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
    programs.agent-skills = {
      enable = true;

      skills.mattpocock = inputs.mattpocock-skills + "/skills";
    };
  };
}
