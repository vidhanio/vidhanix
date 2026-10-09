{ inputs, ... }:
{
  profiles.pc.homeModule =
    {
      inputs',
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.meowland.homeModules.default ];

      programs.meowland = {
        enable = true;
        package = inputs'.meowland.packages.default.overrideAttrs {
          LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.libglvnd ];
        };
      };
    };
}
