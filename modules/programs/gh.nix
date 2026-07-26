{ lib, ... }:
{
  den.default.homeManager =
    { config, ... }:
    let
      cfg = config.programs.gh;
    in
    {
      options.programs.gh.username = lib.mkOption {
        type = lib.types.str;
        description = "GitHub username.";
      };

      config = {
        programs.gh = {
          enable = true;
          settings = {
            git_protocol = "ssh";
          };
          hosts = {
            "github.com" = {
              git_protocol = "ssh";
              users.${cfg.username} = { };
              user = cfg.username;
            };
          };
        };
      };
    };
}
