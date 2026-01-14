{ inputs, ... }:
{
  flake-file.inputs.spicetify-nix.url = "github:Gerg-L/spicetify-nix";

  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      imports = [
        inputs.spicetify-nix.homeManagerModules.default
      ];

      programs.spicetify = {
        enable = pkgs.stdenvNoCC.hostPlatform.isx86_64;
      };

      persist.directories = [ ".config/spotify" ];
    };
}
