{
  flake.modules.homeManager.default = {
    programs.ripgrep.arguments = [ "--hidden" ];
  };
}
