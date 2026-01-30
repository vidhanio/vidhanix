{
  flake.modules.nixos.default = {
    nix.settings.extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
