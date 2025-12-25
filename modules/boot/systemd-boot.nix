{
  flake.modules.nixos.default = {
    boot.loader.systemd-boot.configurationLimit = 10;
  };
}
