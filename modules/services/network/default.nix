{ config, lib, ... }:
let
  inherit (config) hosts;
  inherit (config) users;
in
{
  flake.aspects.network = {
    nixos =
      { config, ... }:
      let
        activeUsers = lib.filterAttrs (
          username: _: hosts.${config.networking.hostName}.users.${username}.enable
        ) users;
        ssids = [
          "EMC2-5G"
          "Vidhan's iPhone"
          "Spongebob"
          "Big388"
        ];

        pskVar =
          ssid:
          "PSK_"
          + lib.toUpper (
            lib.stringAsChars (c: if builtins.match "[A-Za-z0-9]" c != null then c else "_") ssid
          );

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
      in
      {
        users.users = lib.mapAttrs (_: _: {
          extraGroups = [ "networkmanager" ];
        }) activeUsers;

        sops = {
          secrets = lib.listToAttrs (map (ssid: lib.nameValuePair "networks/${ssid}" { }) ssids);

          templates."network-manager.env".content = lib.concatMapStrings (
            ssid: "${pskVar ssid}=${config.sops.placeholder."networks/${ssid}"}\n"
          ) ssids;
        };

        networking.networkmanager = {
          enable = true;
          ensureProfiles = {
            profiles = lib.listToAttrs (map (ssid: lib.nameValuePair ssid (mkWifiProfile ssid)) ssids);
            environmentFiles = [ config.sops.templates."network-manager.env".path ];
          };
        };

        services.resolved.enable = true;
      };
  };
}
