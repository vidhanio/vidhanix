{
  flake.modules.nixos.default = nixos: {
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
