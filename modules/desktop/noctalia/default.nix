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

      programs.noctalia-shell.enable = true;
    };
  };

  configurations.vidhan-pc.homeModule = {
    programs.noctalia-shell.settings = {
      bar.screenOverrides = [
        {
          enabled = true;
          name = "HDMI-A-1";
          position = "bottom";
        }
      ];
      appLauncher = {
        enableClipboardHistory = true;

        terminalCommand = "ghostty -e";

        customLaunchPrefixEnabled = true;
        customLaunchPrefix = "uwsm app --";
      };
      location.name = "Mississauga, Canada";
    };
  };
}
