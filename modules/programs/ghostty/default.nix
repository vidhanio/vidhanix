{ inputs, ... }:
{
  profiles.pc.homeModule =
    { config, pkgs, ... }:
    let
      emoji = {
        package = pkgs.noto-fonts-monochrome-emoji;
        name = "Noto Emoji";
      };
    in
    {
      home.sessionVariables.TERMINAL = "ghostty";
      home.packages = [ emoji.package ];

      stylix.targets.ghostty.fonts.override = { inherit emoji; };

      xdg.configFile."fontconfig/conf.d/50-noto-emoji-monochrome.conf".text = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <match target="pattern">
            <test name="family" qual="first"><string>${emoji.name}</string></test>
            <edit name="color" mode="assign"><bool>false</bool></edit>
          </match>
        </fontconfig>
      '';

      programs.ghostty = {
        enable = true;
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
