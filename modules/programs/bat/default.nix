{
  profiles.base = {
    homeModule = {
      programs.bat.enable = true;
      home.shellAliases.cat = "bat --plain --paging=never";
    };
  };
}
