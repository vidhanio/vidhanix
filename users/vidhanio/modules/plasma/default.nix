{
  lib,
  inputs,
  osConfig,
  ...
}:
{
  imports = with inputs; [ plasma-manager.homeModules.plasma-manager ] ++ lib.importSubmodules ./.;

  programs.plasma = {
    enable = osConfig.services.desktopManager.plasma6.enable or false;
    overrideConfig = true;
    immutableByDefault = true;
  };
}
