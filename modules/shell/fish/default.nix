{
  flake.modules = {
    nixos.default = args: {
      programs.fish.enable = true;
      users.defaultUserShell = args.config.programs.fish.package;
    };
    homeManager.default = {
      programs.fish.enable = true;
    };
  };
}
