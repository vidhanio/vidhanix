{ config, lib, ... }:
let
  cfg = config.programs.spotify-player;
in
lib.mkIf cfg.enable {
  persist.files = [
    ".cache/spotify-player/credentials.json"
  ];
}
