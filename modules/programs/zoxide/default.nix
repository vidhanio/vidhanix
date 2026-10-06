{
  profiles.base = {
    homeModule = {
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
