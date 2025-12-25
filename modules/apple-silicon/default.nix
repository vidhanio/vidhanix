{
  inputs,
  config,
  ...
}:
{
  flake.modules.nixos.apple-silicon = {
    imports = [
      config.flake.modules.nixos.default
      inputs.nixos-apple-silicon.nixosModules.default
    ];
  };
}
