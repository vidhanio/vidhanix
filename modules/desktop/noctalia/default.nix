{ inputs, ... }:
{
  flake-file.inputs.noctalia.url = "github:noctalia-dev/noctalia-shell";

  flake.modules = {
    nixos.default = {
      imports = [
        inputs.noctalia.nixosModules.default
      ];

      services.noctalia-shell.enable = true;
    };
    homeManager.default = {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia-shell = {
        enable = true;
        settings = {
          bar = {
            density = "comfortable";
            outerCorners = false;
            widgets = {
              left = [
                {
                  id = "Clock";
                  formatHorizontal = "yyyy-MM-dd";
                }
                {
                  id = "Clock";
                  formatHorizontal = "HH:mm";
                }
                {
                  id = "Battery";
                  showPowerProfiles = true;
                }
                { id = "Network"; }
                { id = "Bluetooth"; }
                { id = "Volume"; }
                { id = "Brightness"; }
              ];
              center = [
                { id = "Workspace"; }
              ];
              right = [
                { id = "Tray"; }
                { id = "MediaMini"; }
                { id = "NotificationHistory"; }
              ];
            };
          };
          general = {
            showChangelogOnStartup = false;
            telemetryEnabled = false;
            enableShadows = false;
            radiusRatio = 0.5;
            iRadiusRatio = 0.5;
            compactLockScreen = true;
          };
          wallpaper.enabled = false;
          appLauncher = {
            enableClipboardHistory = true;

            terminalCommand = "ghostty -e";

            customLaunchPrefixEnabled = true;
            customLaunchPrefix = "uwsm app --";
          };
          controlCenter = {
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
            ];
          };
          dock.enabled = false;
          location.name = "Mississauga, Canada";
        };
      };
    };
  };

  configurations.vidhan-pc.homeModule = {
    programs.noctalia-shell.settings = {
      bar.monitors = [ "DP-1" ];
    };
  };
}
