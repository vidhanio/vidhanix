_: {
  flake.modules.homeManager.default = _: {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
    };

    persist.directories = [
      ".local/state/opencode"
      ".local/share/opencode"
    ];
  };
}
