{
  profiles.pc = {
    homeModule =
      { config, inputs', ... }:
      let
        inherit (inputs'.llm-agents) packages;
      in
      {
        programs.codex = {
          enable = true;
          enableMcpIntegration = true;
          package = packages.codex;
        };

        home.packages = [ (packages.codex-acp.override { codex = config.programs.codex.package; }) ];

        persist.directories = [ ".codex" ];
      };
  };
}
