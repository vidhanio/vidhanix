{ withSystem, ... }:
{
  flake.modules.nixos.default =
    { config, ... }:
    {
      nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system ({ pkgs, ... }: pkgs);
    };
}
