{
  osConfig,
  lib,
  pkgs,
  ...
}:
lib.optionalAttrs osConfig.desktopManager.plasma6.enable or false {
  xdg.configFile."spectaclerc".text = ''
    [General]
    clipboardGroup=PostScreenshotCopyImage
    useReleaseToCapture=true
  '';
  programs.plasma.spectacle.shortcuts = {
    captureRectangularRegion = "Print";
  };
}
