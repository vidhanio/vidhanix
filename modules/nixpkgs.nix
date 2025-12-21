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
    perSystem = perSystem: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit (perSystem) system;
        inherit (config.nixpkgs) overlays;
        config.allowUnfree = true;
      };
    };

    flake.modules.nixos.base = nixos: {
      nixpkgs.pkgs = withSystem nixos.config.nixpkgs.hostPlatform (perSystem: perSystem.pkgs);
    };
  };

  #     inputs.firefox-addons.overlays.default
  #     inputs.vscode-extensions.overlays.default
}
