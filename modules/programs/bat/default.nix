{
  flake.aspects.bat.homeManager = {
    programs.bat.enable = true;
    home.shellAliases.cat = "bat";
  };
}
