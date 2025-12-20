{ lib, config, ... }:
{
home-manager = {
    sharedModules = 
    users =
      let
        users = lib.filter (user: user.isNormalUser) (lib.attrValues config.users.users);
      in
      lib.genAttrs' users (user: lib.nameValuePair user.name ./users/${user.name});
    useGlobalPkgs = true;
  
};
}
