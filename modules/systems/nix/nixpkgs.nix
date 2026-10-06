{ withSystem, ... }:
{
  profiles.base = {
    module =
      { config, ... }:
      {
        nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system ({ pkgs, ... }: pkgs);
      };
  };
}
