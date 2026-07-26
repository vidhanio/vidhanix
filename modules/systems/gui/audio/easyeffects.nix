{
  den.default.homeManager = {
    services.easyeffects = {
      enable = true;
      preset = "noise-cancel";
      extraPresets.noise-cancel = {
        input = {
          blocklist = [ ];
          "deepfilternet#0" = {
            attenuation-limit = 100.0;
            bypass = false;
            input-gain = 0.0;
            max-df-processing-threshold = 20.0;
            max-erb-processing-threshold = 30.0;
            min-processing-buffer = 0;
            min-processing-threshold = -10.0;
            output-gain = 0.0;
            post-filter-beta = 0.019999999552965164;
          };
          "echo_canceller#0" = {
            bypass = false;
            echo-canceller = {
              automatic-gain-control = false;
              enable = true;
              enforce-high-pass = true;
              mobile-mode = false;
            };
            high-pass = {
              enable = true;
              full-band = true;
            };
            input-gain = 0.0;
            noise-suppression = {
              enable = true;
              level = "Moderate";
            };
            output-gain = 0.0;
          };
          plugins_order = [
            "echo_canceller#0"
            "deepfilternet#0"
          ];
        };
      };
    };
  };
}
