{ lib, ... }:
{
  flake.modules.nixos.default =
    { pkgs, ... }:
    lib.mkMerge [
      {
        programs.steam = {
          enable = true;
        };

        persist.directories = [ ".local/share/Steam" ];
      }
      (lib.mkIf (pkgs.stdenvNoCC.hostPlatform.system == "aarch64-linux") {
        programs.steam.package = pkgs.muvm-steam;

        hardware.graphics = {
          enable32Bit = lib.mkForce false;
        };
      })
    ];
}
