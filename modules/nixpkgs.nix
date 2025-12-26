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
    perSystem = args: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit (args) system;
        inherit (config.nixpkgs) overlays;
        config.allowUnfree = true;
      };
    };

    flake.modules.nixos.base = args: {
      nixpkgs.pkgs = withSystem args.config.nixpkgs.hostPlatform (args: args.pkgs);
    };
  };

  #     inputs.firefox-addons.overlays.default
  #     inputs.vscode-extensions.overlays.default
}
