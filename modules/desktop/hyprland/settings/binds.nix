{
  flake.modules = {
    homeManager.default = {
      wayland.windowManager.hyprland.settings = {
        bind = [
          "SUPER, Q, killactive,"
          "SUPER, M, exec, uwsm stop"
          "SUPER, V, togglefloating,"
          "SUPER, J, togglesplit,"
          "SUPER, F, fullscreen,"
        ];

        bindm = [
          # move/resize windows with SUPER + LMB/RMB and dragging
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        bindel = [
          # volume
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];

        bindl = [
          # playback
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
        ];
      };
    };
  };
}
