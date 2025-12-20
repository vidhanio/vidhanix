{
  inputs,
  config,
  ...
}:
{
  flake-file.inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";

  flake.modules.nixos.macbook = {
    imports = [
      config.flake.modules.nixos.default
      inputs.nixos-apple-silicon.nixosModules.default
    ];
  };
}
