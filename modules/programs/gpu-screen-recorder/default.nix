{
  hosts.vortex.module = {
    programs.gpu-screen-recorder = {
      enable = true;
      ui.enable = true;
    };
  };
  hosts.vortex.homeModule =
    {
      config,
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
        settings = {
          screenshot = {
            take_screenshot_hotkey = disabledHotkey;
            take_screenshot_region_hotkey = disabledHotkey;
            take_screenshot_window_hotkey = disabledHotkey;
          };
          replay = {
            time = 120;
            turn_on_replay_automatically_mode = "turn_on_at_system_startup";
            save_directory = "${config.home.homeDirectory}/Videos";
          };
        };
      };

      xdg.autostart.entries = [
        "${osConfig.programs.gpu-screen-recorder.ui.package}/share/applications/gpu-screen-recorder.desktop"
      ];
    };
}
