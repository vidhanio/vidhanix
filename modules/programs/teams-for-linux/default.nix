{
  flake.aspects.teams-for-linux = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.teams-for-linux ];
        persist.directories = [ ".config/teams-for-linux" ];
      };
  };
}
