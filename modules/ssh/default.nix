{
  flake.modules.nixos.default = {
    services.openssh.enable = true;
  };
}
