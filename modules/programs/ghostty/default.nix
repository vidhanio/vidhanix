{
  flake.aspects.ghostty.homeManager = { config, ... }: {
    home.sessionVariables.TERMINAL = "ghostty";

    programs.ghostty = {
      enable = true;
      systemd.enable = true;

      settings = {
        confirm-close-surface = false;
        gtk-single-instance = true;
        quit-after-last-window-closed = false;
        window-padding-x = config.stylix.padding;
        window-padding-y = config.stylix.padding;
      };
    };

    xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service".source =
      "${config.programs.ghostty.package}/share/systemd/user/app-com.mitchellh.ghostty.service";

    binds."SUPER + SHIFT + t".app = "ghostty";
  };
}
