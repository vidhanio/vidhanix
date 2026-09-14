{
  flake-file = {
    inputs.nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nixConfig = {
      extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
      extra-trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];
    };
    inputs.nix-cachyos-kernel.inputs.nixpkgs.autoFollow = false;
  };

  flake.aspects.cachyos-kernel = {
    nixos =
      { inputs', ... }:
      {
        boot.kernelPackages = inputs'.nix-cachyos-kernel.legacyPackages.linuxPackages-cachyos-latest;
      };
  };
}
