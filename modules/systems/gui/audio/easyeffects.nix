{
  flake.aspects.audio = {
    homeManager =
      { config, ... }:
      let
        cfg = config.services.easyeffects;
      in
      {
        services.easyeffects = {
          enable = true;
          preset = "masc-npr";
          extraPresets.masc-npr = {
            input = {
              blocklist = [ ];
              "compressor#0" = {
                attack = 15;
                boost-amount = 0;
                boost-threshold = -72;
                bypass = false;
                dry = -80.01;
                hpf-frequency = 10;
                hpf-mode = "Off";
                input-gain = 0;
                input-to-link = 0;
                input-to-sidechain = 0;
                knee = -6;
                link-to-input = 0;
                link-to-sidechain = 0;
                lpf-frequency = 20000;
                lpf-mode = "Off";
                makeup = 3;
                mode = "Downward";
                output-gain = 0;
                ratio = 3;
                release = 200;
                release-threshold = -40;
                sidechain = {
                  lookahead = 0;
                  mode = "RMS";
                  preamp = 0;
                  reactivity = 10;
                  source = "Middle";
                  stereo-split-source = "Left/Right";
                  type = "Feed-forward";
                };
                sidechain-to-input = 0;
                sidechain-to-link = 0;
                stereo-split = false;
                threshold = -18;
                wet = 0;
              };
              "deepfilternet#0" = {
                attenuation-limit = 100;
                bypass = false;
                input-gain = 0;
                max-df-processing-threshold = 20;
                max-erb-processing-threshold = 30;
                min-processing-buffer = 0;
                min-processing-threshold = 5;
                output-gain = 0;
                post-filter-beta = 0.019999999552965164;
              };
              "deesser#0" = {
                bypass = false;
                detection = "RMS";
                f1-freq = 4000;
                f1-level = -6;
                f2-freq = 8000;
                f2-level = -6;
                f2-q = 1.5;
                input-gain = 0;
                laxity = 15;
                makeup = 0;
                mode = "Split";
                output-gain = 0;
                ratio = 3;
                sc-listen = false;
                threshold = -22;
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
                input-gain = 0;
                noise-suppression = {
                  enable = true;
                  level = "Moderate";
                };
                output-gain = 0;
              };
              "equalizer#0" = {
                balance = 0.1;
                bypass = false;
                input-gain = 0;
                left = {
                  band0 = {
                    frequency = 80;
                    gain = 0;
                    mode = "RLC (BT)";
                    mute = false;
                    q = 0.7;
                    slope = "x2";
                    solo = false;
                    type = "Hi-pass";
                    width = 4;
                  };
                  band1 = {
                    frequency = 220;
                    gain = -2;
                    mode = "RLC (MT)";
                    mute = false;
                    q = 0.7;
                    slope = "x1";
                    solo = false;
                    type = "Bell";
                    width = 4;
                  };
                  band2 = {
                    frequency = 350;
                    gain = -2;
                    mode = "BWC (MT)";
                    mute = false;
                    q = 1.2;
                    slope = "x2";
                    solo = false;
                    type = "Bell";
                    width = 4;
                  };
                  band3 = {
                    frequency = 3500;
                    gain = 2;
                    mode = "BWC (BT)";
                    mute = false;
                    q = 0.9;
                    slope = "x2";
                    solo = false;
                    type = "Bell";
                    width = 4;
                  };
                  band4 = {
                    frequency = 10000;
                    gain = 2;
                    mode = "LRX (MT)";
                    mute = false;
                    q = 0.7;
                    slope = "x1";
                    solo = false;
                    type = "Hi-shelf";
                    width = 4;
                  };
                };
                mode = "IIR";
                num-bands = 5;
                output-gain = 0;
                pitch-left = 0;
                pitch-right = 0;
                right = {
                  band0 = {
                    frequency = 80;
                    gain = 0;
                    mode = "RLC (BT)";
                    mute = false;
                    q = 0.7;
                    slope = "x2";
                    solo = false;
                    type = "Hi-pass";
                    width = 4;
                  };
                  band1 = {
                    frequency = 220;
                    gain = -2;
                    mode = "RLC (MT)";
                    mute = false;
                    q = 0.7;
                    slope = "x1";
                    solo = false;
                    type = "Bell";
                    width = 4;
                  };
                  band2 = {
                    frequency = 350;
                    gain = -2;
                    mode = "BWC (MT)";
                    mute = false;
                    q = 1.2;
                    slope = "x2";
                    solo = false;
                    type = "Bell";
                    width = 4;
                  };
                  band3 = {
                    frequency = 3500;
                    gain = 2;
                    mode = "BWC (BT)";
                    mute = false;
                    q = 0.9;
                    slope = "x2";
                    solo = false;
                    type = "Bell";
                    width = 4;
                  };
                  band4 = {
                    frequency = 10000;
                    gain = 2;
                    mode = "LRX (MT)";
                    mute = false;
                    q = 0.7;
                    slope = "x1";
                    solo = false;
                    type = "Hi-shelf";
                    width = 4;
                  };
                };
                split-channels = false;
              };
              "gate#0" = {
                attack = 5;
                bypass = false;
                curve-threshold = -50;
                curve-zone = -2;
                dry = -80.01;
                hpf-frequency = 10;
                hpf-mode = "Off";
                hysteresis = true;
                hysteresis-threshold = -3;
                hysteresis-zone = -1;
                input-gain = 0;
                input-to-link = 0;
                input-to-sidechain = 0;
                link-to-input = 0;
                link-to-sidechain = 0;
                lpf-frequency = 20000;
                lpf-mode = "Off";
                makeup = 1;
                output-gain = 0;
                reduction = -12;
                release = 250;
                sidechain = {
                  lookahead = 0;
                  mode = "RMS";
                  preamp = 0;
                  reactivity = 10;
                  source = "Middle";
                  stereo-split-source = "Left/Right";
                  type = "Internal";
                };
                sidechain-to-input = 0;
                sidechain-to-link = 0;
                stereo-split = false;
                wet = -1;
              };
              "limiter#0" = {
                alr = false;
                alr-attack = 5;
                alr-knee = 0;
                alr-release = 50;
                attack = 2;
                bypass = false;
                dithering = "16bit";
                gain-boost = false;
                input-gain = 0;
                input-to-link = 0;
                input-to-sidechain = 0;
                link-to-input = 0;
                link-to-sidechain = 0;
                lookahead = 2;
                mode = "Herm Wide";
                output-gain = 0;
                oversampling = "None";
                release = 5;
                sidechain-preamp = 0;
                sidechain-to-input = 0;
                sidechain-to-link = 0;
                sidechain-type = "Internal";
                stereo-link = 100;
                threshold = -1.5;
              };
              plugins_order = [
                "echo_canceller#0"
                "rnnoise#0"
                "deepfilternet#0"
                "gate#0"
                "equalizer#0"
                "compressor#0"
                "deesser#0"
                "limiter#0"
              ];
              "rnnoise#0" = {
                bypass = false;
                enable-vad = false;
                input-gain = 0;
                model-name = "\"\"";
                output-gain = 0;
                release = 20;
                use-standard-model = true;
                vad-thres = 30;
                wet = 0;
              };
            };
          };
        };

        systemd.user.services.easyeffects.Service.ExecStartPost = [
          "${cfg.package}/bin/easyeffects --load-preset ${cfg.preset}"
        ];
      };
  };
}
