{
  profiles.base = {
    module = {
      boot.loader.systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
    };
  };
}
