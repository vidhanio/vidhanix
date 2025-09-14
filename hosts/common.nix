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
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
  };

  users.defaultUserShell = pkgs.fish;

  programs = {
    fish.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
    ];

    variables = {
      EDITOR = "nvim";
    };

    shellAliases = {
      vi = "nvim";
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays =
      with inputs;
      [
        agenix.overlays.default
        rust-overlay.overlays.default
        # vidhanix-fonts.overlays.default
      ]
      ++ map import (lib.readDirToList ../overlays);
  };
}
