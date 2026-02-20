{
  flake.modules.nixos.default = {
    services.fwupd.enable = true;
  };
}
