{
  withSystem,
  ...
}:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    withSystem pkgs.stdenvNoCC.hostPlatform.system (
      { self', ... }:
      {
        home.packages = [
          self'.packages.helium-bin
        ];

        persist.directories = [ ".config/net.imput.helium" ];
      }
    );
}
