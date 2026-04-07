{ lib, withSystem, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, config, ... }:
    let
      cfg = config.programs.xtool;
    in
    {
      options.programs.xtool = {
        enable = lib.mkEnableOption "xtool";
        package = lib.mkOption {
          type = lib.types.package;
          default = withSystem pkgs.stdenv.hostPlatform.system ({ self', ... }: self'.packages.xtool-bin);
          description = "The xtool package to use.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];
      };
    };
}
