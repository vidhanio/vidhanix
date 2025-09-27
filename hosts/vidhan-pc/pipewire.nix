{
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
          microphone = "usb-352f_PD100X_Podcast_Microphone_214b206000000178-00";
          speakers = "usb-Creative_Technology_Ltd_Creative_Pebble_Pro_MF1710-01";
          webcam = "usb-Linux_Foundation_USB_Webcam_gadget-02";

          mkRule = name: update-props: {
            matches = [ { "device.name" = "alsa_card.${name}"; } ];
            actions.update-props = update-props;
          };

          setProfile = profile: {
            "device.profile" = profile;
          };

          disable = {
            "device.disabled" = true;
          };
        in
        {
          "monitor.alsa.rules" = [
            (mkRule microphone (setProfile "input:mono-fallback"))
            (mkRule speakers (setProfile "output:analog-stereo"))
            (mkRule webcam disable)
          ];
        };
    };
  };
}
