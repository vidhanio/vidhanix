{ lib, ... }:
{
  flake.aspects.gnome.nixos =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.hardware.monitors;
      monitors = [ cfg.main ] ++ cfg.others;
      identityFields = [
        "vendor"
        "product"
        "serial"
      ];
      isConfigured =
        monitor: monitor.mode != null && lib.all (field: monitor.${field} != null) identityFields;
      allConfigured = lib.all isConfigured monitors;

      renderMode = mode: ''
        <mode>
          <width>${toString mode.width}</width>
          <height>${toString mode.height}</height>
          <rate>${lib.strings.floatToString mode.refreshRate}</rate>
        </mode>
      '';

      renderMonitor = primary: monitor: ''
                  <logicalmonitor>
                    <x>${toString monitor.position.x}</x>
                    <y>${toString monitor.position.y}</y>
                    <scale>${lib.strings.floatToString monitor.scale}</scale>
                    ${lib.optionalString primary "<primary>yes</primary>\n            "}
                    <monitor>
                      <monitorspec>
                        <connector>${lib.escapeXML monitor.name}</connector>
                        <vendor>${lib.escapeXML monitor.vendor}</vendor>
                        <product>${lib.escapeXML monitor.product}</product>
                        <serial>${lib.escapeXML monitor.serial}</serial>
                      </monitorspec>
        ${renderMode monitor.mode}
                    </monitor>
                  </logicalmonitor>
      '';

      monitorsXml = pkgs.writeText "gnome-monitors.xml" (
        lib.trim ''
          <?xml version="1.0"?>
          <monitors version="2">
            <configuration>
              <layoutmode>logical</layoutmode>
          ${renderMonitor true cfg.main}${lib.concatMapStrings (renderMonitor false) cfg.others}</configuration>
          </monitors>
        ''
      );
    in
    {
      environment.etc."xdg/monitors.xml" = lib.mkIf allConfigured {
        source = monitorsXml;
      };
    };

  flake.aspects.gnome.homeManager.dconf.settings."org/gnome/mutter".experimental-features = [
    "variable-refresh-rate"
    "scale-monitor-framebuffer"
  ];
}
