{
  flake.aspects.fastfetch = {
    homeManager = {
      programs.fastfetch = {
        enable = true;
        settings = {
          display = {
            key = {
              width = 8;
            };
            separator = " ";
          };
          logo = {
            source = "nixos_old_small";
          };
          modules = [
            "title"
            {
              type = "os";
              key = "os";
            }
            {
              type = "host";
              key = "host";
            }
            {
              type = "kernel";
              key = "kernel";
            }
            {
              type = "uptime";
              key = "uptime";
            }
            {
              type = "memory";
              key = "memory";
            }
          ];
        };
      };
    };
  };
}
