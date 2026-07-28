{
  flake.modules.homeManager.default = {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;

      settings.permissions.defaultMode = "auto";
    };

    persist = {
      directories = [ ".claude" ];
      files = [ ".claude.json" ];
    };
  };
}
