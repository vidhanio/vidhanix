{ inputs, ... }:
{
  flake-file.inputs.mattpocock-skills = {
    url = "github:mattpocock/skills";
    flake = false;
  };

  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.opencode = {
        enable = true;
        package = inputs'.llm-agents.packages.opencode;
        settings = {
          permission = "allow";
          skills.paths = [ "${inputs.mattpocock-skills}/skills" ];
        };
      };

      persist.directories = [ ".local/share/opencode" ];
    };
}
