{
  profiles.pc = {
    homeModule =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.python315 ];
      };
  };
}
