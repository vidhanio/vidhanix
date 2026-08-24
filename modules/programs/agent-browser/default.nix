{
  flake.aspects.agent-browser = {
    homeManager = { inputs', ... }: {
      programs.agent-browser = {
        enable = true;

        # the packaged input carries the agent-browser skill in its source,
        # wired up by the options module.
        package = inputs'.llm-agents.packages.agent-browser;
      };

      # restore states and daemon state under ~/.agent-browser survive reboots
      persist.directories = [ ".agent-browser" ];
    };
  };
}
