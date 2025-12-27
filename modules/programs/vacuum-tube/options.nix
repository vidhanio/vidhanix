{
  flake.modules.homeManager.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.programs.vacuum-tube;
      json = pkgs.formats.json { };
    in
    {
      options.programs.vacuum-tube = {
        enable = lib.mkEnableOption "VacuumTube";
        package = lib.mkPackageOption pkgs "vacuum-tube";
        settings = lib.mkOption {
          inherit (json) type;
          default = { };
          description = "VacuumTube settings written to {file}`$XDG_CONFIG_HOME/VacuumTube/config.json`.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];

        xdg.configFile."VacuumTube/config.json" = lib.mkIf (cfg.settings != { }) {
          source = json.generate "vacuumtube-config" cfg.settings;
        };
      };
    };
}
