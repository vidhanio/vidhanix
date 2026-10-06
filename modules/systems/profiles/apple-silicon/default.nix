{ inputs, ... }:
{
  flake-file.inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";

  flake.aspects =
    { aspects, ... }:
    {
      apple-silicon = {
        includes = with aspects; [
          gui

          # keep-sorted start
          disk.provides.apple-silicon
          disk.provides.impermanence.provides.btrfs
          steam.provides.apple-silicon
          # keep-sorted end
        ];
        nixos =
          {
            lib,
            pkgs,
            self',
            ...
          }:
          {
            imports = [ inputs.nixos-apple-silicon.nixosModules.default ];
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
      };
    };
}
