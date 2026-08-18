{
  flake.aspects.mcp.homeManager = {
    # Shared MCP servers; harnesses with enableMcpIntegration pull them in.
    programs.mcp.enable = true;
  };
}
