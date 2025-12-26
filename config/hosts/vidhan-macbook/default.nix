{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.stateVersion = "26.05";
}
