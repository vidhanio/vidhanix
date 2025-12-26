{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.helium;
in
{
  options.programs.helium = {
    enable = lib.mkEnableOption "Helium browser";
    package = lib.mkPackageOption pkgs "helium-bin" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    persist.directories = [ ".config/net.imput.helium" ];
  };
}
