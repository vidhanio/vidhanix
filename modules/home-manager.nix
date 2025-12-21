{
  inputs,
  config,
  lib,
  ...
}:
{
  flake.modules.nixos.default = nixos: {
    imports = [ inputs.home-manager.nixosModules.default ];

    home-manager = {
      sharedModules = [ config.flake.modules.homeManager.default ];
      useGlobalPkgs = true;
      users =
        let
          nixosUsers = lib.filter (user: user.isNormalUser) (lib.attrValues nixos.config.users.users);
        in
        lib.genAttrs;
    };
  };
}
