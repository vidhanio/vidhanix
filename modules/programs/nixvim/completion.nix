{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim.plugins = {
      blink-cmp.enable = true;
      lazydev.enable = true;
    };
  };
}
