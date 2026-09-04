{
  config,
  ...
}:
let
  flakeUsers = config.users;
in
{
  flake.aspects.jujutsu = {
    homeManager =
      { config, ... }:
      {
        programs.jujutsu = {
          enable = true;
          settings.user =
            let
              user = flakeUsers.${config.home.username};
            in
            {
              name = user.fullName;
              inherit (user) email;
            };
        };
      };
  };
}
