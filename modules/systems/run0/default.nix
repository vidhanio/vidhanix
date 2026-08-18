{ config, lib, ... }:
let
  inherit (config) hosts;
  inherit (config) users;
in
{
  flake.aspects.run0 = {
    nixos =
      { config, ... }:
      let
        activeUsers = lib.filterAttrs (
          username: _: hosts.${config.networking.hostName}.users.${username}.enable
        ) users;
      in
      {
        security.sudo.enable = false;

        security.run0 = {
          enable = true;
          wheelNeedsPassword = false;
          sudo-shim.enable = true;
        };

        users.users = lib.mapAttrs (_: _: {
          extraGroups = [ "wheel" ];
        }) activeUsers;
      };
  };
}
