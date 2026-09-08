{
  flake.aspects.valent.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.valent ];

      programs.gnome-shell.extensions = [
        { package = pkgs.gnomeExtensions.valent; }
      ];

      systemd.user.services.valent = {
        Unit = {
          Description = "Connect, control, and sync devices";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install.WantedBy = [ "graphical-session.target" ];

        Service = {
          ExecStart = "${pkgs.valent}/bin/valent --gapplication-service";
          Restart = "on-abort";
        };
      };
    };
}
