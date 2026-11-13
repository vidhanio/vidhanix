{
  profiles.pc.module = {
    programs.gpu-screen-recorder = {
      enable = true;
      ui.enable = true;
    };
  };
  profiles.pc.homeModule =
    {
      config,
      lib,
      osConfig,
      ...
    }:
    let
      disabledHotkey = {
        key = 0;
        modifiers = 0;
      };
    in
    {
      programs.gpu-screen-recorder-ui = {
        enable = true;
        package = null;
        mutableSettings = false;
        settings = lib.mkMerge [
          {
            screenshot = {
              take_screenshot_hotkey = disabledHotkey;
              take_screenshot_region_hotkey = disabledHotkey;
              take_screenshot_window_hotkey = disabledHotkey;
            };
            replay = {
              time = 120;
              save_directory = "${config.home.homeDirectory}/Videos";
            };
          }
          (lib.mkIf (osConfig.hardware.asahi.enable or false) {
            record.record_options.codec = "h264_software";
            replay.record_options.codec = "h264_software";
            streaming.record_options.codec = "h264_software";
          })
        ];
      };

      xdg.autostart.entries = [
        "${osConfig.programs.gpu-screen-recorder.ui.package}/share/applications/gpu-screen-recorder.desktop"
      ];
    };

  hosts.vortex.homeModule.programs.gpu-screen-recorder-ui.settings.replay = {
    turn_on_replay_automatically_mode = "turn_on_at_system_startup";
  };
}
