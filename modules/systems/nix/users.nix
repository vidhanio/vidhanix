{
  flake.modules.nixos.default = {
    nix.settings = {
      allowed-users = [ "@wheel" ];
      trusted-users = [ "@wheel" ];
    };
  };
}
