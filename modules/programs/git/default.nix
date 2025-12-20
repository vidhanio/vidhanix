{
  config,
  ...
}:
let
  flakeUsers = config.users;
in
{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user =
            let
              user = flakeUsers.${config.home.username};
            in
            {
              name = user.fullName;
              inherit (user) email;
            };

          init.defaultBranch = "main";

          push.autoSetupRemote = true;
          pull.rebase = true;
          rebase.autostash = true;
          merge.ff = "only";
          submodule.recurse = true;

          url."git@github.com:".insteadOf = "https://github.com/";
        };
        lfs.enable = true;
      };
    };
}
