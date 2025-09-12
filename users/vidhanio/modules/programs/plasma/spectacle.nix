{
  programs.plasma = {
    configFile."spectaclerc" = {
      General = {
        clipboardGroup = "PostScreenshotCopyImage";
        useReleaseToCapture = true;
      };
    };
    spectacle.shortcuts = {
      captureRectangularRegion = "Print";
    };
  };
}
