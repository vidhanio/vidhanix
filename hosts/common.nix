{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home-manager = {
    users =
      with builtins;
      mapAttrs (name: _: ../users/${name}) (
        lib.filterAttrs (
          _: user: (user.isNormalUser or true) && !(lib.hasPrefix "_" user.name)
        ) config.users.users
      );
    sharedModules = [ ../users/common.nix ];
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
  };

  fonts.packages = with pkgs; [
    berkeley-mono-variable
    pragmata-pro-variable
    jetbrains-mono
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays =
      with inputs;
      [
        agenix.overlays.default
        rust-overlay.overlays.default
        vidhanix-fonts.overlays.default
      ]
      ++ map import (lib.readDirToList ../overlays);
  };
}
