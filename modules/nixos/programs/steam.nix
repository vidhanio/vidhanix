{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.steam;
in
{
  options.programs.steam = {

  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        persist.directories = [ ".local/share/Steam" ];
      }
    ];
  };
}
