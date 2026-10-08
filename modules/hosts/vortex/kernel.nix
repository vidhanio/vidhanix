{
  perSystem.treefmt.programs.flake-edit.settings.follow.ignore = [ "nix-cachyos-kernel.nixpkgs" ];

  hosts.vortex = {
    module =
      { inputs', ... }:
      {
        boot.kernelPackages = inputs'.nix-cachyos-kernel.legacyPackages.linuxPackages-cachyos-latest;
      };
  };
}
