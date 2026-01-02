{
  config,
  ...
}:
{
  flake.modules.nixos.pc = {
    imports = [
      config.flake.modules.nixos.default
    ];
  };
}
