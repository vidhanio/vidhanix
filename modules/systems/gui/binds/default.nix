{ lib, ... }:
{
  flake.aspects.binds.homeManager =
    _:
    let
      msg = command: "noctalia msg ${command}";
      mediaBind = flags: command: {
        exec = msg command;
        locked = flags.locked or false;
        repeating = flags.repeating or false;
      };
      repeating = mediaBind {
        repeating = true;
        locked = true;
      };
      locked = mediaBind { locked = true; };
    in
    {
      binds =
        lib.mergeAttrsList (
          map (i: {
            "SUPER + ${toString i}" = {
              hyprland.dsp.focus = {
                workspace = i;
                on_current_monitor = true;
              };
              niri.action.focus-workspace = i;
            };
            "SUPER + SHIFT + ${toString i}" = {
              hyprland.dsp."window.move" = {
                workspace = i;
                follow = false;
              };
              niri.action.move-column-to-workspace = i;
            };
          }) (lib.range 1 9)
        )
        // {
          "SUPER + Q" = {
            hyprland.dsp."window.close" = { };
            niri.action.close-window = { };
          };
          "SUPER + M" = {
            hyprland.dsp.exec_cmd = "uwsm stop";
            niri.action.quit._props.skip-confirmation = true;
          };
          "SUPER + V".exec = msg "panel-toggle clipboard";
          "SUPER + J" = {
            hyprland.dsp.layout = "togglesplit";
            niri.action.toggle-column-tabbed-display = { };
          };
          "SUPER + F" = {
            hyprland.dsp."window.fullscreen" = { };
            niri.action.fullscreen-window = { };
          };

          "SUPER + Tab" = {
            hyprland.enable = false;
            niri.action.focus-workspace-down = { };
          };
          "SUPER + SHIFT + Tab" = {
            hyprland.enable = false;
            niri.action.focus-workspace-up = { };
          };

          "Print".exec = msg "screenshot-region";
          "SUPER + P".exec = msg "screenshot-region";

          "SUPER + e".exec = msg "panel-toggle launcher";

          "XF86AudioRaiseVolume" = repeating "volume-up";
          "XF86AudioLowerVolume" = repeating "volume-down";
          "XF86AudioMute" = repeating "volume-mute";
          "XF86AudioMicMute" = repeating "mic-mute";

          "XF86MonBrightnessUp" = repeating "brightness-up";
          "XF86MonBrightnessDown" = repeating "brightness-down";
          "SHIFT + XF86MonBrightnessUp" = repeating "keyboard-backlight-up";
          "SHIFT + XF86MonBrightnessDown" = repeating "keyboard-backlight-down";

          "XF86AudioPlay" = locked "media toggle";
          "XF86AudioPause" = locked "media toggle";
          "XF86AudioNext" = locked "media next";
          "XF86AudioPrev" = locked "media previous";
        };
    };
}
