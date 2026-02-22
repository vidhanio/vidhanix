{
  flake.modules.homeManager.default = {
    programs.yazi.enable = true;

    persist.directories = [ ".local/state/yazi" ];
  };
}
