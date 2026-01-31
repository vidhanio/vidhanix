{
  flake.modules.nixos.default = {
    services.tuned.enable = true;
  };
}
