{
  flake.modules.homeManager.default = {
    persist.files = [
      {
        file = ".local/share/fish/fish_history";
        method = "symlink";
      }
    ];
  };
}
