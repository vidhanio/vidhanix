{
  flake.aspects.python = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.python315 ];
      };
  };
}
