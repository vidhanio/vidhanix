{
  config,
  pkgs,
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
        user: lib.nameValuePair user.name ../users/${user.name}
      );
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
  };

  users.defaultUserShell = pkgs.fish;

  programs = {
    fish.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
    ];

    variables = {
      EDITOR = "nvim";
    };

    shellAliases = {
      vi = "nvim";
    };
  };

  nix.enable = lib.mkIf config.nixpkgs.hostPlatform.isDarwin false;
}
