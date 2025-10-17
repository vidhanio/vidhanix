{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.programs.cider-2;
in
{
  options.programs.cider-2 = {
    enable = lib.mkEnableOption "Cider";

    package = lib.mkPackageOption pkgs "cider-2" { };
  };

  config = lib.mkIf (osConfig.nixpkgs.hostPlatform.isLinux && cfg.enable) {
    home.packages = [ cfg.package ];

    impermanence.directories = [ ".config/sh.cider.genten" ];
  };
}
