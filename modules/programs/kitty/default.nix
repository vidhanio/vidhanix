{
  flake.aspects.kitty = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.kitty;
        innerPadding = builtins.div config.stylix.padding 2;
      in
      {
        home.sessionVariables.TERMINAL = "kitty";

        programs.kitty = {
          enable = true;

          package = pkgs.symlinkJoin {
            inherit (pkgs.kitty) pname version meta;
            paths = [ pkgs.kitty ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/kitty \
                --add-flags "--single-instance"
            '';
          };

          settings = {
            confirm_os_window_close = 0;
            window_padding_width = config.stylix.padding;
          };

          quickAccessTerminalConfig = {
            edge = "top";
            lines = "720px";
            layer = "overlay";
            background_opacity = 0.85;
            hide_on_focus_loss = true;
            start_as_hidden = true;
            margin_top = innerPadding;
            margin_left = innerPadding;
            margin_right = innerPadding;
          };
        };

        binds."SUPER + SHIFT + t".app = "kitty";

        systemd.user.services.kitty-daemon = {
          Unit = {
            Description = "Kitty single-instance daemon";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };

          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            ExecStart = "${lib.getExe cfg.package} --start-as hidden";
            Restart = "always";
            RestartSec = 1;
          };
        };
      };
  };
}
