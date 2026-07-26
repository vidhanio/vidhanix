{
  den.default.homeManager = {
    programs.ripgrep = {
      enable = true;
      arguments = [ "--hidden" ];
    };
    home.shellAliases.grep = "rg";
  };
}
