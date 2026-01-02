{
  withSystem,
  ...
}:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = withSystem pkgs.stdenvNoCC.hostPlatform.system (
        { self', ... }: [ self'.packages.helium-bin ]
      );

      persist.directories = [ ".config/net.imput.helium" ];
    };
}
