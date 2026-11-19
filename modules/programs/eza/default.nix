{
  profiles.base = {
    homeModule = {
      programs.eza = {
        enable = true;
        enableNushellIntegration = true;
        git = true;
        extraOptions = [
          "--all"
          "--group-directories-first"
        ];
      };
      home.shellAliases = {
        ls = "eza";
        tree = "eza --tree";
      };
    };
  };
}
