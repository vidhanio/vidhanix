{
  flake.modules.nixos.default = {
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
