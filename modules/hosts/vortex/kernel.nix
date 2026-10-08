{
  hosts.vortex = {
    module =
      { inputs', ... }:
      {
        boot.kernelPackages = inputs'.nix-cachyos-kernel.legacyPackages.linuxPackages-cachyos-latest;
      };
  };
}
