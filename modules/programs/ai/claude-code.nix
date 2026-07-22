{
  flake.modules.homeManager.default = {
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
