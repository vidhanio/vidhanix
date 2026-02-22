_: {
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        package = pkgs.opencode;
      };
    };
}
