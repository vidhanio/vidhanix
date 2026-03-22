{
  flake.modules.homeManager.default = {
    programs.mcp = {
      enable = true;
      servers.minecraft = {
        url = "http://localhost:8080/mcp";
      };
    };
  };
}
