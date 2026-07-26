{
  den.default.homeManager = {
    programs.spotify-player.enable = true;
    persist.files = [
      ".cache/spotify-player/credentials.json"
    ];
  };
}
