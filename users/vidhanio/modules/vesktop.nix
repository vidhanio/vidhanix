{ ... }:
{
  programs.vesktop = {
    enable = true;
    settings = {
      discordBranch = "canary";
      tray = true;
      minimizeToTray = true;
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
      arRPC = true;
      customTitlebar = true;
    };
    vencord.settings = {
      autoUpdate = false;
    };
  };
}
