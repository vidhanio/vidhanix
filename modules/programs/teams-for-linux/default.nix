{
  profiles.pc = {
    homeModule =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.teams-for-linux ];
        persist.directories = [ ".config/teams-for-linux" ];
      };
  };
}
