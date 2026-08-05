{
  flake.modules.nixos.default = {
    services.tzupdate.enable = true;
  };
}
