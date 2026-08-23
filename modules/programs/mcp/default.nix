{
  flake.aspects.mcp = {
    homeManager = {
      # shared MCP servers; harnesses with enableMcpIntegration pull them in.
      programs.mcp.enable = true;
    };
  };
}
