{
  flake.modules = {
    nixos.default =
      { config, ... }:
      {
        programs.fish.enable = true;
        users.defaultUserShell = config.programs.fish.package;
      };
    homeManager.default =
      { pkgs, ... }:
      {
        programs.fish.enable = true;

        # Fish is the login shell; silence the pre-shell login banner.
        home.file.".hushlogin".source = pkgs.emptyFile;
      };
  };
}
