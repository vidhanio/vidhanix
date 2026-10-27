{ inputs, ... }:
{
  profiles.pc.homeModule = { config, inputs', ... }: {
    home.sessionVariables.TERMINAL = "ghostty";

    programs.ghostty = {
      enable = true;
      package = inputs'.ghostty.packages.default;
      systemd.enable = true;

      settings = {
        clipboard-read = "allow";
        confirm-close-surface = false;
        custom-shader = "${inputs.cursor-shaders}/ghostty/cursor_warp.glsl";
        gtk-single-instance = true;
        quit-after-last-window-closed = false;
        window-padding-x = config.stylix.padding;
        window-padding-y = config.stylix.padding;
      };
    };

    xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service".source =
      "${config.programs.ghostty.package}/share/systemd/user/app-com.mitchellh.ghostty.service";
  };
}
