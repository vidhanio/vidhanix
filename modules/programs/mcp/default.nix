{
  flake.aspects.mcp.homeManager = _: {
    # Shared MCP servers; harnesses with enableMcpIntegration pull them in.
    programs.mcp.enable = true;
  };
}
