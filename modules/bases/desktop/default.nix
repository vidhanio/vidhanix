{
  config,
  ...
}:
{
  flake.modules.nixos.desktop = {
    imports = [
      config.flake.modules.nixos.default
    ];
  };
}
