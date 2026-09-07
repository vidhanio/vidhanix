{
  flake.aspects.nushell = {
    nixos =
      { config, ... }:
      {
        programs.nushell.enable = true;
        users.defaultUserShell = config.programs.nushell.package;
      };
    homeManager =
      { pkgs, ... }:
      {
        programs.nushell = {
          enable = true;
          settings = {
            show_banner = false;
            edit_mode = "vi";
          };
        };

        programs.carapace = {
          enable = true;
          enableNushellIntegration = true;
        };

        # Silence the pre-shell login banner.
        home.file.".hushlogin".source = pkgs.emptyFile;
      };
  };
}
