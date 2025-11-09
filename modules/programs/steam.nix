{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.steam;
in
lib.mkIf cfg.enable {
  home-manager.sharedModules = [
    {
      persist.directories = [ ".local/share/Steam" ];
    }
  ];
}
