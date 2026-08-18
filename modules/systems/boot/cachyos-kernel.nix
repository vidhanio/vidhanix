{
  flake-file = {
    inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nixConfig = {
      extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
      extra-trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];
    };
    prune-lock.ignore = [ "nix-cachyos-kernel" ];
  };

  flake.aspects.cachyos-kernel = {
    nixos =
      {
        inputs',
        lib,
        pkgs,
        ...
      }:
      {
        boot.kernelPackages = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 inputs'.nix-cachyos-kernel.legacyPackages.linuxPackages-cachyos-latest;
      };
  };
}
