{
  flake.aspects.eza.homeManager = {
    programs.eza = {
      enable = true;
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
}
