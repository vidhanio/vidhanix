{ inputs, lib, ... }:
{
  flake-file.inputs.spicetify-nix.url = "github:Gerg-L/spicetify-nix";

  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.spicetify-nix.homeManagerModules.default
      ];

      config = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        programs.spicetify = {
          enable = true;
        };

        xdg.autostart.entries = [
          "${config.programs.spicetify.spicedSpotify}/share/applications/spotify.desktop"
        ];

        hyprland.autostartWorkspaces.spotify = 2;

        persist.directories = [ ".config/spotify" ];
      };
    };
}
