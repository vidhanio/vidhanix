{
  flake.aspects.zoxide = {
    homeManager = {
      programs.zoxide = {
        enable = true;
        enableNushellIntegration = true;
        options = [
          "--cmd"
          "cd"
        ];
      };

      persist.directories = [ ".local/share/zoxide" ];
    };
  };
}
