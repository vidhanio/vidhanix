{ lib, ... }:
{
  flake.modules.nixos.default =
    { config, ... }:
    {
      age.secrets.networks.file = ../../secrets/networks.age;

      networking.networkmanager = {
        enable = true;
        ensureProfiles = {
          environmentFiles = [ config.age.secrets.networks.path ];
          profiles =
            let
              mkWifiProfile = id: psk: {
                connection = {
                  inherit id;
                  type = "wifi";
                };
                wifi.ssid = id;
                wifi-security = {
                  key-mgmt = "wpa-psk";
                  inherit psk;
                };
              };
            in
            lib.mapAttrs mkWifiProfile {
              EMC2-5G = "$EMC2";
              "Vidhan's iPhone" = "$IPHONE";
              Spongebob = "$SPONGEBOB";
            };
        };
      };

      services.resolved.enable = true;
    };
}
