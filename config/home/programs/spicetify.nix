{ config, lib, ... }:
let
  cfg = config.programs.spicetify;
in
lib.mkMerge [
  {
    programs.spicetify = {
      wayland = false;
    };
  }
  (lib.mkIf cfg.enable {
    persist.directories = [ ".config/spotify" ];
  })
]
