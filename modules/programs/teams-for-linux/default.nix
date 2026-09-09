{
  flake.aspects.teams-for-linux = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.teams-for-linux ];
      };
  };
}
