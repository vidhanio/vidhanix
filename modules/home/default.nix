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
    sharedModules =
      with inputs;
      lib.readSubmodules ./.
      ++ [
        impermanence.homeManagerModules.default
        agenix.homeManagerModules.default
        nixcord.homeModules.default
        ../../users/shared.nix
      ];
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
  };
}
