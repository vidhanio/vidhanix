{
  xdg.configFile."spectaclerc".text = ''
    [General]
    clipboardGroup=PostScreenshotCopyImage
    useReleaseToCapture=true
  '';
  programs.plasma.spectacle.shortcuts = {
    captureRectangularRegion = "Print";
  };
}
