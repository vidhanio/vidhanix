{
  config,
  ...
}:
let
  inherit (config) people;
in
{
  den.default.homeManager =
    { config, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user =
            let
              person = people.${config.home.username};
            in
            {
              name = person.fullName;
              inherit (person) email;
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
