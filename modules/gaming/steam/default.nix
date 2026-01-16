{ lib, withSystem, ... }:
{
  flake.modules = {
    nixos.default =
      { pkgs, ... }:
      lib.mkMerge [
        {
          programs.steam.enable = true;
        }
        (lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch64-linux") {
          programs.steam.package = withSystem pkgs.stdenv.hostPlatform.system (
            { self', ... }: self'.packages.muvm-steam
          );

          hardware.graphics = {
            enable32Bit = lib.mkForce false;
          };
        })
      ];
    homeManager.default = {
      persist.directories = [ ".local/share/Steam" ];
    };
  };
}
