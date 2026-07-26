{ lib, ... }:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default = {
    nixos = {
      home-manager.useGlobalPkgs = true;
    };

    homeManager =
      { osConfig, ... }:
      {
        home.stateVersion = osConfig.system.stateVersion;
      };
  };
}
