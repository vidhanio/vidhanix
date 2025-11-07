{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.steam;
  gnomeEnable = config.services.desktopManager.gnome.enable;
in
lib.mkIf cfg.enable {
  environment.systemPackages =
    with pkgs;
    lib.mkIf gnomeEnable [
      adwsteamgtk
    ];

  home-manager.sharedModules = [
    {
      persist.directories = [ ".local/share/Steam" ];
    }
  ];
}
