{ inputs, ... }:
{
  flake.modules.homeManager.default = {
    imports = [
      inputs.spicetify-nix.homeModules.default
    ];

    programs.spicetify = {
      enable = true;
      wayland = false;
    };
    persist.directories = [ ".config/spotify" ];
  };
}
