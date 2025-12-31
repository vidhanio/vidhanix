{
  flake.modules = {
    nixos.default =
      { config, ... }:
      {
        programs.fish.enable = true;
        users.defaultUserShell = config.programs.fish.package;
      };
    homeManager.default = {
      programs.fish.enable = true;
    };
  };
}
