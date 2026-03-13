{
  flake.modules.nixos.default = {
    security.sudo.enable = false;
    security.sudo-rs.enable = true;
  };
}
