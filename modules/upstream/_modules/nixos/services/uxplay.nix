{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.uxplay;

  settingsValue = lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.str
  ];

  renderSetting =
    name: value:
    if value == null || value == false then
      [ ]
    else if value == true then
      [ name ]
    else if lib.isList value then
      lib.concatMap (renderSetting name) value
    else if lib.isString value then
      [ ''${name} "${value}"'' ]
    else
      [ "${name} ${toString value}" ];

  configFile = pkgs.writeText "uxplayrc" (
    lib.concatLines (lib.concatLists (lib.mapAttrsToList renderSetting cfg.settings))
  );
in
{
  options.services.uxplay = {
    enable = lib.mkEnableOption "UxPlay, an AirPlay mirroring and audio streaming server";

    package = lib.mkPackageOption pkgs "uxplay" { };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open the TCP and UDP ports selected by
        {option}`services.uxplay.settings.p` in the firewall.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf (
          lib.types.nullOr (lib.types.either settingsValue (lib.types.listOf settingsValue))
        );

        options.p = lib.mkOption {
          type = lib.types.nullOr lib.types.port;
          default = null;
          example = 7100;
          description = ''
            The first of three consecutive TCP and UDP ports to listen on.
            Ports are chosen dynamically when null.
          '';
        };
      };
      default = { };
      example = {
        n = "Living Room";
        nh = true;
        p = 7100;
        as = "pipewiresink";
        vs = "waylandsink";
        fs = true;
        allow = [
          "00:11:22:33:44:55"
          "66:77:88:99:AA:BB"
        ];
      };
      description = ''
        Options written to the {file}`uxplayrc` startup file. Attribute names
        are command-line options without the leading `-`. `true` passes a bare
        flag, `false` and `null` omit the option, strings are passed as a
        single quoted argument, and lists repeat the option once per element.

        See {manpage}`uxplay(1)` for available options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.openFirewall -> cfg.settings.p != null;
        message = "services.uxplay.openFirewall requires services.uxplay.settings.p to be set.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    services.avahi = {
      enable = true;
      settings.publish = {
        disable-publishing = false;
        disable-user-service-publishing = false;
        publish-addresses = true;
      };
    };

    networking.firewall = lib.mkIf (cfg.openFirewall && cfg.settings.p != null) (
      let
        range = {
          from = cfg.settings.p;
          to = cfg.settings.p + 2;
        };
      in
      {
        allowedTCPPortRanges = [ range ];
        allowedUDPPortRanges = [ range ];
      }
    );

    systemd.user.services.uxplay = {
      description = "AirPlay Unix mirroring server";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      restartTriggers = [ configFile ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} -rc ${configFile}";
        Restart = "on-failure";
      };
    };
  };
}
