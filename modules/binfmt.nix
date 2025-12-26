{ lib, ... }:
{
  flake.modules.nixos.default = args: {
    # make binfmt available for non-native architectures
    binfmt.emulatedSystems =
      let
        inherit (args.config.nixpkgs.hostPlatform) system;
        mkSystemIfNot = target: lib.mkIf (system != target) [ target ];
      in
      lib.mkMerge [
        (mkSystemIfNot "aarch64-linux")
        (mkSystemIfNot "x86_64-linux")
      ];
  };
}
