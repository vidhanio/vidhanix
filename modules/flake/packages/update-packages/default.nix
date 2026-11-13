{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.update-packages =
        lib.addMetaAttrs
          {
            description = "Update all packages in this flake that have an update script";
          }
          (
            pkgs.writers.writeNuBin "update-packages" {
              makeWrapperArgs = [
                "--prefix"
                "PATH"
                ":"
                (lib.makeBinPath [ pkgs.nix-update ])
              ];
            } ./update-packages.nu
          );
    };
}
