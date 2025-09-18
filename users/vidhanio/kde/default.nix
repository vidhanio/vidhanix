{
  lib,
  inputs,
  osConfig,
  ...
}:
{
  imports = with inputs; [ plasma-manager.homeModules.plasma-manager ] ++ lib.readSubmodules ./.;

  programs.plasma = {
    enable = osConfig.services.desktopManager.plasma6.enable or false;
    overrideConfig = true;

    configFile = {
      plasmaparc = {
        General.AudioFeedback = false;
      };
    };
  };

  impermanence.directories = [
    ".local/share/kwalletd"
  ];
}
