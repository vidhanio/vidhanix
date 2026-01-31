{
  flake.modules = {
    homeManager.default =
      let
        noctalia = "noctalia-shell ipc call";
      in
      {
        wayland.windowManager.hyprland.settings = {
          bind = [
            "SUPER, Space, exec, ${noctalia} launcher toggle"
          ];

          bindel = [
            # brightness
            ", XF86MonBrightnessUp, exec, ${noctalia} brightness increase"
            ", XF86MonBrightnessDown, exec, ${noctalia} brightness decrease"

            # volume
            ", XF86AudioRaiseVolume, exec, ${noctalia} volume increase"
            ", XF86AudioLowerVolume, exec, ${noctalia} volume decrease"
            ", XF86AudioMute, exec, ${noctalia} volume muteOutput"
            ", XF86AudioMicMute, exec, ${noctalia} volume muteInput"
          ];

          bindl = [
            # playback
            ", XF86AudioPrev, exec, ${noctalia} media previous"
            ", XF86AudioNext, exec, ${noctalia} media next"
            ", XF86AudioPlay, exec, ${noctalia} media playPause"
          ];
        };
      };
  };
}
