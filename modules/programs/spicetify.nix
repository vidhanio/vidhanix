{ inputs, ... }:
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

      programs.spicetify = {
        enable = pkgs.stdenvNoCC.hostPlatform.isx86_64;
      };

      xdg.autostart.entries = [
        "${config.programs.spicetify.spicedSpotify}/share/applications/spotify.desktop"
      ];

      hyprland.autostartWorkspaces.spotify = 2;

      persist.directories = [ ".config/spotify" ];
    };
}
