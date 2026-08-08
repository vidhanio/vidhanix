{
  flake-file.inputs.mattpocock-skills = {
    url = "github:mattpocock/skills";
    flake = false;
  };

  flake.modules.homeManager.default = _: {
    programs.agents.skills = {
      enable = true;

      sources.mattpocock = {
        input = "mattpocock-skills";
        subdir = "skills";
      };

      skills.enableAll = true;

      targets.agents.enable = true;
    };
  };
}
