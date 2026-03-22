{
  flake.modules.homeManager.default = {
    programs.lazygit = {
      enable = true;
    };

    persist.directories = [ ".local/state/lazygit" ];
  };
}
