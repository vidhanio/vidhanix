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
            barType = "floating";
            floating = true;
            density = "comfortable";
            marginVertical = 10;
            marginHorizontal = 10;
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
                { id = "Battery"; }
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
          general.enableShadows = false;
          wallpaper.enabled = false;
          appLauncher = {
            enableShadows = true;
            enableClipboardHistory = true;

            terminalCommand = "ghostty -e";

            customLaunchPrefixEnabled = true;
            customLaunchPrefix = "uwsm app --";
          };
          controlCenter = {
            left = [
              { id = "Network"; }
              { id = "Bluetooth"; }
            ];
            right = [
              { id = "KeepAwake"; }
              { id = "NightLight"; }
            ];
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
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
