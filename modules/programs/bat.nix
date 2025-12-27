{
  flake.modules.homeManager.default = {
    programs.bat.enable = true;
    home.shellAliases.cat = "bat";
  };
}
