{ lib, ... }:
{
  flake.modules.nixos.default =
    { pkgs, config, ... }:
    {
      # make binfmt available for non-native architectures
      boot.binfmt.emulatedSystems =
        let
          mkSystemIfNot = target: lib.mkIf (pkgs.stdenvNoCC.hostPlatform.system != target) [ target ];
        in
        lib.mkMerge [
          (mkSystemIfNot "aarch64-linux")
          (mkSystemIfNot "x86_64-linux")
        ];
    };
}
