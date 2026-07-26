{
  den.default.homeManager = {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
    };

    persist = {
      directories = [ ".claude" ];
      files = [ ".claude.json" ];
    };
  };
}
