{
  flake.aspects.zoxide = {
    homeManager = {
      programs.zoxide = {
        enable = true;
        options = [
          "--cmd"
          "cd"
        ];
      };

      persist.directories = [ ".local/share/zoxide" ];
    };
  };
}
