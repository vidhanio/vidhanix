{
  flake.modules = {
    nixos.default = {
      services.pipewire = {
        enable = true;
        wireplumber.extraConfig = {
          "00-default-volume" =
            let
              cube = n: n * n * n;
            in
            {
              "wireplumber.settings" = {
                "device.routes.default-sink-volume" = cube 0.6;
              };
            };

          "01-device-profiles" =
            let
              mkRule = name: update-props: {
                matches = [ { "device.name" = "alsa_card.${name}"; } ];
                actions.update-props = update-props;
              };

              setProfile = profile: {
                "device.profile" = profile;
              };

              microphone = "usb-352f_PD100X_Podcast_Microphone_214b206000000178-00";
              speakers = "usb-Creative_Technology_Ltd_Creative_Pebble_Pro_MF1710-01";
            in
            {
              "monitor.alsa.rules" = [
                (mkRule microphone (setProfile "input:mono-fallback"))
                (mkRule speakers (setProfile "output:analog-stereo"))
              ];
            };
        };
      };
    };
    homeManager.default = {
      wayland.windowManager.hyprland.settings.bindel =
        let
          mkSetVolume =
            sign:
            "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%${sign}";
        in
        [
          ", XF86AudioLowerVolume, exec, ${mkSetVolume "-"}"
          ", XF86AudioRaiseVolume, exec, ${mkSetVolume "+"}"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];
    };
  };
}
