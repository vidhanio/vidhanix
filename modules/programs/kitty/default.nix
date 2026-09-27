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
