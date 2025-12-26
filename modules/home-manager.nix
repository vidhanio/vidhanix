{
  inputs,
  config,
  ...
}:
{
  flake.modules.nixos.default = args: {
    imports = [ inputs.home-manager.nixosModules.default ];

    home-manager = {
      sharedModules = with config.flake.modules.homeManager; [ default ];
      useGlobalPkgs = true;
    };

    programs.home-manager.enable = true;
  };
}
