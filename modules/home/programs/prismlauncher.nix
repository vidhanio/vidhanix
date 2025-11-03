{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.prismlauncher;
in
{
  options.programs.prismlauncher = {
    enable = lib.mkEnableOption "Prism Launcher";
    package = lib.mkPackageOption pkgs "prismlauncher" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    persist.directories = [ ".local/share/PrismLauncher" ];
  };
}
