{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.stylix.targets.gnome;
  gnomeCfg = config.programs.gnome-shell;
in
lib.mkIf (cfg.enable && gnomeCfg.enable) {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.lockscreen-extension;
    }
  ];

  dconf.settings."org/gnome/shell/extensions/lockscreen-extension" =
    with config.lib.stylix.colors.withHashtag; {
      hide-lockscreen-extension-button = true;
      user-background-1 = false;

      primary-color-1 = base00;
      secondary-color-1 = base08;
    };
}
