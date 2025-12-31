{
  inputs,
  lib,
  config,
  withSystem,
  ...
}:
{
  options.nixpkgs = {
    overlays = lib.mkOption {
      type = lib.types.listOf lib.types.function;
      default = [ ];
    };
  };

  config = {
    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          inherit (config.nixpkgs) overlays;
          config.allowUnfree = true;
        };
      };

    flake.modules.nixos.base =
      { config, ... }:
      {
        nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform ({ pkgs, ... }: pkgs);
      };
  };

  #     inputs.firefox-addons.overlays.default
  #     inputs.vscode-extensions.overlays.default
}
