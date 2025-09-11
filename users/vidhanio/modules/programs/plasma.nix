{ osConfig, lib, pkgs, ... }: lib.optionalAttrs osConfig.desktopManager.plasma6.enable or false {
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    workspace.colorScheme = "BreezeDark";
  };
}
