{
  flake.modules.homeManager.default = {
    stylix.targets.waybar = {
      addCss = false;
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings.main = {
        modules-left = [
          "clock"
          "tray"
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
          tooltip = true;
          tooltip-format = ''
            {:%A, %B %d, %Y
            %H:%M:%S
            Week: %V
            Day of Year: %j
            %Z (%z)}'';
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };

        "hyprland/workspaces" = {
          all-outputs = true;
          move-to-monitor = true;
          sort-by = "number";
          format = "{name}";
        };

        bluetooth = {
          format-disabled = "󰂲 off";
          format-off = "󰂲 off";
          format-on = "󰂯 on";
          format-connected = "󰂱 {num_connections}";
          tooltip-format = ''
            Bluetooth Device: {controller_alias}
            {status}'';
          tooltip-format-connected = ''
            Bluetooth Device: {controller_alias}
            {num_connections} connected
            {device_enumerate}'';
          tooltip-format-enumerate-connected = "• {device_alias}";
        };

        network = {
          interval = 5;
          family = "ipv4_6";
          format-wifi = "{icon} {essid}";
          format-ethernet = "󰈀 {ifname}";
          format-linked = "󰈀 {ifname} (no IP)";
          format-disconnected = "󰖪 offline";
          format-disabled = "󰖪 off";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          tooltip-format-wifi = ''
            Wi-Fi: {essid}
            Signal: {signalStrength}% ({signaldBm} dBm)
            IP: {ipaddr}
            GW: {gwaddr}'';
          tooltip-format-ethernet = ''
            Ethernet: {ifname}
            IP: {ipaddr}
            GW: {gwaddr}'';
          tooltip-format-disconnected = "No active network";
        };

        wireplumber = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 muted";
          on-scroll-up = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
          format-icons = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
          tooltip-format = ''
            Audio Output: {node_name}
            Volume: {volume}%
            Input: {source_desc} ({source_volume}%)'';
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-full = "󰁹 full";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip-format = ''
            Battery: {capacity}%
            Power: {power:.1f}W
            Remaining: {time}
            Status: {status}'';
        };
      };
      style = ''
        window#waybar {
          color: @base05;
          background-color: transparent;
        }

        tooltip {
          color: @base05;
          background: @base00;
          border: 2px solid @base05;
          border-radius: 0;
          box-shadow: none;
          padding: 8px;
        }

        #workspaces {
          padding: 4px;
        }

        #workspaces button {
          padding: 0 4px;
          border-radius: 0;
          border: 2px solid transparent;
          color: @base04;
        }

        #workspaces button.visible {
          color: @base05;
        }

        #workspaces button.empty {
          opacity: 0.65;
        }

        #workspaces button.active {
          color: @base05;
        }

        #workspaces button.visible.hosting-monitor,
        #workspaces button.active.hosting-monitor {
          color: @base0D;
        }

        #workspaces button.urgent {
          background: @base08;
          color: @base00;
          border-color: @base08;
        }

        .module {
          background: @base00;
          padding: 8px;
          border: 2px solid @base05;
        }

        #bluetooth.connected,
        #network.wifi,
        #network.ethernet,
        #wireplumber,
        #battery {
          color: @base0B;
        }

        #bluetooth.off,
        #bluetooth.disabled,
        #bluetooth.no-controller,
        #wireplumber.muted,
        #wireplumber.sink-muted,
        #wireplumber.source-muted,
        #battery.warning,
        #battery.critical,
        #network.disconnected,
        #network.disabled {
          color: @base08;
        }

        #battery.charging,
        #battery.plugged {
          color: @base0D;
        }
      '';
    };
  };
}
