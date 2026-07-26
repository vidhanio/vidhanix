{
  den.default.homeManager = {
    programs.mcp = {
      enable = true;
      servers.minecraft = {
        url = "http://localhost:8080/mcp";
      };
    };
  };
}
