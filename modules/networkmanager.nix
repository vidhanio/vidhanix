{ lib, config, ... }:
{
  age.secrets.networks.file = ../secrets/networks.age;

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [ config.age.secrets.networks.path ];
      profiles =
        let
          mkWifiProfile = id: pskVar: {
            connection = {
              inherit id;
              type = "wifi";
            };
            wifi.ssid = id;
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$PSK_${pskVar}";
            };
          };
        in
        lib.mapAttrs mkWifiProfile {
          EMC2-5G = "EMC2";
          "Vidhan's iPhone" = "IPHONE";
        };
    };
  };
}
