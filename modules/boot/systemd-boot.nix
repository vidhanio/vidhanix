{ lib, ... }:
{
  flake.modules.nixos.default = {
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
      # https://github.com/nix-community/nixos-apple-silicon/pull/416
      consoleMode = lib.mkForce "max";
    };
  };
}
