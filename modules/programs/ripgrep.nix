{
  flake.modules.homeManager.default = {
    programs.ripgrep = {
      enable = true;
      arguments = [ "--hidden" ];
    };
  };
}
