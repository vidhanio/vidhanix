{
  config,
  lib,
  inputs,
  ...
}:
{
  home-manager = {
    users =
      let
        isNormalUser = user: (user.isNormalUser or true) && !(lib.hasPrefix "_" user.name);
      in
      lib.genAttrs' (builtins.filter isNormalUser (builtins.attrValues config.users.users)) (
        user: lib.nameValuePair user.name ../../users/${user.name}
      );
    useGlobalPkgs = true;
    sharedModules =
      with inputs;
      [
        impermanence.homeManagerModules.default
        agenix.homeManagerModules.default
        nixcord.homeModules.default
        ../../users/shared.nix
      ]
      ++ lib.readSubmodules ./.;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
  };
}
