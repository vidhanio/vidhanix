{
  flake.modules.homeManager.default = {
    stylix.targets.waybar = {
      addCss = false;
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings.main = {
        layer = "top";

        modules-left = [
          "clock"
        ];

        modules-center = [
          "hyprland/workspaces"
        ];

        modules-right = [
          "bluetooth"
          "network"
          "wireplumber"
          "battery"
        ];

        margin-top = 8;
        margin-left = 8;
        margin-right = 8;
        spacing = 8;

        clock = {
          format = "{:%F %R}";
        };

        "hyprland/workspaces" = {
          all-outputs = true;
          move-to-monitor = true;
        };

        # "custom/hello-from-waybar" = {
        #   format = "hello {}";
        #   max-length = 40;
        #   interval = "once";
        #   exec = pkgs.writeShellScript "hello-from-waybar" ''
        #     echo "from within waybar"
        #   '';
        # };
      };
      style = ''
        window#waybar,
        tooltip {
          color: @base05;
          border-color: @base0D;
        }

        window#waybar {
          background-color: transparent;
        }

        #workspaces {
          padding: 4px;
        }

        #workspaces button {
          padding: 0 4px;
          border-radius: 0;
        }

        .module {
          background: @base00;
          padding: 8px;
          border: 2px solid @base05;
        }
      '';
    };
  };
}
