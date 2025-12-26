{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.steam;
in
{
  config = {
    home-manager.sharedModules = [
      {
        persist.directories = [ ".local/share/Steam" ];
      }
    ];
  };
}
