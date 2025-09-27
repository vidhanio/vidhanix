{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.cider-2;
in
{
  options.programs.cider-2.enable = lib.mkEnableOption "Cider";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.cider-2 ];

    impermanence.directories = [ ".config/sh.cider.genten" ];
  };
}
