{
  flake.modules.nixos.default = {
    nix.settings.extra-trusted-users = [ "@wheel" ];
  };
}
