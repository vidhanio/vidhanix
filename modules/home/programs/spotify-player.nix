{ config, lib, ... }:
let
  cfg = config.programs.spotify-player;
in
lib.mkIf cfg.enable {
  impermanence.files = [
    ".cache/spotify-player/credentials.json"
  ];
}
