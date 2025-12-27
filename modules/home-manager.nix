{
  inputs,
  config,
  ...
}:
{
  flake.modules = {
    nixos.default = {
      imports = [ inputs.home-manager.nixosModules.default ];

      home-manager = {
        sharedModules = with config.flake.modules.homeManager; [ default ];
        useGlobalPkgs = true;
      };
    };
    homeManager.default = {
      programs.home-manager.enable = true;
    };
  };
}
