{ lib, withSystem, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, config, ... }:
    let
      cfg = config.programs.helium;
    in
    {
      options.programs.helium = {
        enable = lib.mkEnableOption "Helium browser";
        package = lib.mkOption {
          type = lib.types.package;
          default = withSystem pkgs.stdenv.hostPlatform.system ({ self', ... }: self'.packages.helium-bin);
          description = "The Helium browser package to use.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];
      };
    };
}
