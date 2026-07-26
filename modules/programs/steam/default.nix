{ lib, withSystem, ... }:
{
  den.default = {
    nixos =
      { pkgs, ... }:
      lib.mkMerge [
        {
          programs.steam.enable = true;

          hardware.steam-hardware.enable = true;
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
    homeManager = {
      persist.directories = [ ".local/share/Steam" ];
    };
  };

  den.aspects.vidhan-pc.provides.to-users.homeManager =
    { osConfig, ... }:
    {
      xdg.autostart.entries = [ "${osConfig.programs.steam.package}/share/applications/steam.desktop" ];

      hyprland.autostartWorkspaces.steam = 3;
    };
}
