{
  profiles.pc.homeModule =
    { lib, pkgs, ... }:
    {
      home.packages = [ pkgs.valent ];

      systemd.user.services.valent = {
        Unit = {
          Description = "Connect, control, and sync devices";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install.WantedBy = [ "graphical-session.target" ];

        Service = {
          ExecStart = "${lib.getExe pkgs.valent} --gapplication-service";
          Restart = "on-abort";
        };
      };
    };
}
