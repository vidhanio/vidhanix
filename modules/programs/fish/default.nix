{
  flake.aspects.fish = {
    nixos =
      { config, ... }:
      {
        programs.fish.enable = true;
        users.defaultUserShell = config.programs.fish.package;
      };
    homeManager =
      { pkgs, ... }:
      {
        programs.fish.enable = true;

        # fish is the login shell; silence the pre-shell login banner.
        home.file.".hushlogin".source = pkgs.emptyFile;
      };
  };
}
