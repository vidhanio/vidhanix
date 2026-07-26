{
  den.default.nixos = {
    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
  };
}
