{
  flake.aspects.fx = {
    homeManager =
      { inputs', ... }:
      {
        programs.fx = {
          enable = true;
          enableMcpIntegration = true;

          package = inputs'.llm-agents.packages.fx;

          # the nix package is the update channel; fx is Vercel AI Gateway
          # only, so the model comes from the Gateway catalog.
          settings = {
            auto_upgrade = false;
          };
        };

        persist.directories = [ ".fx" ];
      };
  };
}
