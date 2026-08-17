{
  flake.aspects.boot.nixos = {
    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
  };
}
