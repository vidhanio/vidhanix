{
  flake.modules.nixos.default = {
    programs.steam.enable = true;
  };
  flake.modules.homeManager.default = {
    persist.directories = [ ".local/share/Steam" ];
  };
}
