{
  flake.modules.homeManager.default =
    { inputs', ... }:
    let
      pkg = inputs'.llm-agents.packages.agent-browser;
    in
    {
      # Shared MCP server; harnesses' enableMcpIntegration pulls it into their configs.
      programs.mcp.servers.agent-browser = {
        command = "${pkg}/bin/agent-browser";
        args = [ "mcp" ];
      };

      # Vendored stub (IFD is off); the CLI serves version-matched content via `skills get core`.
      programs.agents.skills.skills.agent-browser = ./SKILL.md;

      persist.directories = [ ".agent-browser" ];
    };
}
