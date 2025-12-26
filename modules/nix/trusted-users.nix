{
  flake.modules.nixos.default = args: {
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
