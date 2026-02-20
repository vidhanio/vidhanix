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
        margin-left = 12;
        margin-right = 12;
        spacing = 8;

        clock = {
          format = "{:%F %R}";
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

        #workspaces button {
          padding: 0 4px;
        }

        .module {
          background: @base00;
          padding: 4px;
          border-radius: 12px;
        }

        .module:not(#workspaces) {
          padding: 4px 8px;
        }
      '';
    };
  };
}
