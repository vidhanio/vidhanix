{
  flake.modules.homeManager.default = {
    programs.spotify-player.enable = true;
    persist.files = [
      ".cache/spotify-player/credentials.json"
    ];
  };
}
