{
  flake.aspects.nushell = {
    nixos =
      { config, ... }:
      {
        programs.nushell.enable = true;
        users.defaultUserShell = config.programs.nushell.package;
      };
    homeManager =
      { lib, pkgs, ... }:
      {
        programs.nushell = {
          enable = true;
          settings = {
            show_banner = false;
            edit_mode = "vi";
            cursor_shape = {
              vi_insert = "line";
              vi_normal = "block";
            };
            table.mode = "thin";
          };
          environmentVariables.PROMPT_COMMAND_RIGHT = lib.hm.nushell.mkNushellInline ''
            {||
              let fail_color = if (config use-colors) {
                ansi red_bold
              } else {
                ""
              }
              if ($env.LAST_EXIT_CODE != 0) {
                ([$fail_color $env.LAST_EXIT_CODE] | str join)
              } else {
                ""
              }
            }
          '';
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
