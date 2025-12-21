{
  inputs,
  config,
  ...
}:
{
  flake.modules.nixos.default = nixos: {
    imports = [ inputs.home-manager.nixosModules.default ];

    home-manager = {
      sharedModules = with config.flake.modules.homeManager; [ default ];
      useGlobalPkgs = true;
    };
  };
}
