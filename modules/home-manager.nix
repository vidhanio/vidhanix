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
    homeManager.default =
      { osConfig, ... }:
      {
        programs.home-manager.enable = true;

        home.stateVersion = osConfig.system.stateVersion;
      };
  };
}
