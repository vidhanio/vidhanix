{
  flake.modules.homeManager.default = {
    programs.zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    programs.fish.functions.c = ''
      if test (count $argv) -eq 0
        code-insiders
      else
        code-insiders (zoxide query -- $argv)
      end
    '';

    persist.directories = [ ".local/share/zoxide" ];
  };
}
