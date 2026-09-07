{
  flake.aspects.fish = {
    nixos =
      { config, ... }:
      {
        programs.fish.enable = true;
        programs.fish.shellInit = ''
          fish_vi_key_bindings
        '';
        users.defaultUserShell = config.programs.fish.package;
      };
    homeManager =
      { pkgs, ... }:
      {
        programs.fish.enable = true;

        programs.carapace = {
          enable = true;
          enableFishIntegration = true;
        };

        # fish is the login shell; silence the pre-shell login banner.
        home.file.".hushlogin".source = pkgs.emptyFile;
      };
  };
}
