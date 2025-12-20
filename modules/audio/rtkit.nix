{
  flake.modules.nixos.default = {
    security.rtkit.enable = true;
  };
}
