{
  withSystem,
  ...
}:
{
  flake.modules = {
    nixos.default =
      {
        pkgs,
        config,
        ...
      }:
      {
        stylix = {
          cursor = {
            package = withSystem pkgs.stdenv.hostPlatform.system (
              { self', ... }:
              self'.packages.breezex-combined.override (
                with config.lib.stylix.colors.withHashtag;
                {
                  baseColor = base01;
                  outlineColor = base07;
                }
              )
            );
            name = "BreezeX Cursor";
            size = 32;
          };
        };
      };
    homeManager.default = {
      home.pointerCursor.hyprcursor.enable = true;
    };
  };
}
