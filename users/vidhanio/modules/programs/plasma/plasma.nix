{ config, ... }:
{
  programs.plasma = {
    workspace.lookAndFeel = "org.kde.breezedark.desktop";
    panels = [
      {

      }
    ];
  };
}
