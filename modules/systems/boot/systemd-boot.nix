{
  flake.modules.nixos.default = {
    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
  };
}
