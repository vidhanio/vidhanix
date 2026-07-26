{
  den.default = {
    nixos =
      { config, ... }:
      {
        programs.fish.enable = true;
        users.defaultUserShell = config.programs.fish.package;
      };
    homeManager = {
      programs.fish.enable = true;
    };
  };
}
