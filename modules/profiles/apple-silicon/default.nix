{ config, inputs, ... }:
{
  profiles.apple-silicon = {
    module =
      {
        lib,
        pkgs,
        self',
        ...
      }:
      {
        imports = [
          config.profiles.pc.module
          inputs.nixos-apple-silicon.nixosModules.default
        ];
        hardware.asahi.enable = true;
        # TODO: remove once nix-community/nixos-apple-silicon#559 is merged
        hardware.asahi.overlay =
          lib.composeExtensions
            (import "${inputs.nixos-apple-silicon}/apple-silicon-support/packages/overlay.nix")
            (
              final: prev: {
                uboot-asahi = prev.uboot-asahi.overrideAttrs (old: {
                  makeFlags = old.makeFlags ++ [ "DTC=${lib.getExe final.buildPackages.dtc}" ];
                });
              }
            );
        boot.kernelPackages = lib.mkForce (
          pkgs.linuxPackagesFor self'.packages.linux-asahi-fairydust.kernel
        );
      };
    homeModule.imports = [ config.profiles.pc.homeModule ];
  };
}
