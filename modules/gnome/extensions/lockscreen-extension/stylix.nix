{
  flake.modules.homeManager.default = args: {
    dconf.settings."org/gnome/shell/extensions/lockscreen-extension" =
      with args.config.lib.stylix.colors.withHashtag; {
        hide-lockscreen-extension-button = true;

        user-background-1 = false;
        primary-color-1 = base00;
        secondary-color-1 = base08;

        user-background-2 = false;
        primary-color-2 = base00;
        secondary-color-3 = base08;
      };
  };
}
