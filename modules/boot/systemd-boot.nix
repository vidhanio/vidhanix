{
  flake.modules.nixos.default = {
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
      consoleMode = "max";
    };
  };
}
