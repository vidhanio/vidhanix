{
  flake.aspects.zed-editor = {
    homeManager = {
      programs.zed-editor = {
        enable = true;

        userSettings = {
          vim_mode = true;

          vim = {
            use_system_clipboard = "always";
            use_smartcase_find = true;
            use_regex_search = true;
            gdefault = true;
            toggle_relative_line_numbers = true;
          };
        };
      };

      persist.directories = [ ".local/share/zed" ];
    };
  };
}
