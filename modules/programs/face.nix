{
  config,
  lib,
  ...
}:
let
  flakeUsers = config.users;
in
{
  flake.aspects.face = {
    homeManager =
      { config, ... }:
      let
        face = flakeUsers.${config.home.username}.face;
      in
      {
        home.file.".face" = lib.mkIf (face != null) {
          source = face;
        };
      };
  };
}
