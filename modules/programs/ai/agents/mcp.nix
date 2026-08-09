{
  flake.modules.homeManager.default = _: {
    # Shared MCP server definitions ({option}`programs.mcp.servers`) that the
    # agents' `enableMcpIntegration` options pull into their own configs.
    programs.mcp.enable = true;
  };
}
