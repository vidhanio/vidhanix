{
  flake.modules.homeManager.default = {
    programs.dolphin-emu = {
      enable = true;
      settings = {
        Analytics.PermissionAsked = true;
        Core = {
          EnableWiiLink = true;
          WiimoteContinuousScanning = true;
          WiimoteEnableSpeaker = true;
          WiiSDCardAllowWrites = true;
          WiiSDCardEnableFolderSync = true;
          WiiSDCardFilesize = 0;
        };
      };
    };

    persist.directories = [ ".local/share/dolphin-emu" ];
  };
}
