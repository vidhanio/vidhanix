{
  flake.aspects.agent-browser = {
    homeManager =
      { inputs', config, ... }:
      let
        cfg = config.programs.agent-browser;
      in
      {
        programs.agent-browser = {
          enable = true;
          package = inputs'.llm-agents.packages.agent-browser;
          settings = {
            headed = true;
            autoConnect = true;
          };
        };

        programs.agents.skills.agent-browser = "${cfg.package.src}/skills/agent-browser";

        # restore states and daemon state under ~/.agent-browser survive reboots
        persist.directories = [ ".agent-browser" ];
      };
  };
}
