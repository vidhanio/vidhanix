{ lib, config, ... }:
{
  boot = {
    loader.systemd-boot.configurationLimit = 10;

    binfmt.emulatedSystems =
      let
        inherit (config.nixpkgs.hostPlatform) system;
        mkSystemIfNot = target: lib.mkIf (system != target) [ target ];
      in
      lib.mkMerge [
        (mkSystemIfNot "aarch64-linux")
        (mkSystemIfNot "x86_64-linux")
      ];
  };
}
