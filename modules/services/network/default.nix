{ lib, ... }:
{
  flake.aspects.network = {
    nixos =
      { config, ... }:
      let
        ssids = [
          "EMC2-5G"
          "Vidhan's iPhone"
          "Spongebob"
          "Big388"
        ];

        pskVar =
          ssid:
          "PSK_"
          + lib.toUpper (lib.stringAsChars (c: if lib.match "[A-Za-z0-9]" c != null then c else "_") ssid);

        mkWifiProfile = ssid: {
          connection = {
            id = ssid;
            type = "wifi";
          };
          wifi = { inherit ssid; };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "\$${pskVar ssid}";
          };
        };

        macWifiProfile = {
          connection = {
            id = "Mac-WiFi";
            type = "wifi";
          };
          wifi = {
            ssid = "Mac-WiFi";
          };
          wifi-security.key-mgmt = "wpa-eap";
          "802-1x" = {
            eap = "peap;";
            identity = "\$MAC_WIFI_USERNAME";
            password = "\$MAC_WIFI_PASSWORD";
            phase2-auth = "mschapv2";
          };
        };
      in
      {
        sops = {
          secrets = lib.listToAttrs (map (ssid: lib.nameValuePair "networks/${ssid}" { }) ssids) // {
            "networks/Mac-WiFi/username" = { };
            "networks/Mac-WiFi/password" = { };
          };

          templates."network-manager.env".content =
            lib.concatMapStrings (ssid: "${pskVar ssid}=${config.sops.placeholder."networks/${ssid}"}\n") ssids
            + ''
              MAC_WIFI_USERNAME=${config.sops.placeholder."networks/Mac-WiFi/username"}
              MAC_WIFI_PASSWORD=${config.sops.placeholder."networks/Mac-WiFi/password"}
            '';
        };

        networking.networkmanager = {
          enable = true;
          ensureProfiles = {
            profiles = lib.listToAttrs (map (ssid: lib.nameValuePair ssid (mkWifiProfile ssid)) ssids) // {
              "Mac-WiFi" = macWifiProfile;
            };
            environmentFiles = [ config.sops.templates."network-manager.env".path ];
          };
        };

        services.resolved.enable = true;
      };
  };
}
