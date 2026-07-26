{ lib, ... }:
{
  den.default = {
    nixos =
      { config, ... }:
      let
        ssids = [
          "EMC2-5G"
          "Vidhan's iPhone"
          "Spongebob"
          "Big388"
        ];

        mkWifiProfile = ssid: {
          connection = {
            id = ssid;
            type = "wifi";
          };
          wifi.ssid = ssid;
          wifi-security.key-mgmt = "wpa-psk";
        };

        mkWifiSecret = ssid: {
          matchId = ssid;
          matchType = "802-11-wireless";
          matchSetting = "802-11-wireless-security";
          key = "psk";
          file = config.sops.secrets."networks/${ssid}".path;
        };
      in
      {
        sops.secrets = lib.listToAttrs (map (ssid: lib.nameValuePair "networks/${ssid}" { }) ssids);

        networking.networkmanager = {
          enable = true;
          ensureProfiles = {
            profiles = lib.listToAttrs (map (ssid: lib.nameValuePair ssid (mkWifiProfile ssid)) ssids);
            secrets.entries = map mkWifiSecret ssids;
          };
        };

        services.resolved.enable = true;
      };
    homeManager = {
      services.network-manager-applet.enable = true;
    };
  };
}
