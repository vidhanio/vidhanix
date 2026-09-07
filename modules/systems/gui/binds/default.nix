{ lib, ... }:
{
  flake.aspects.binds.homeManager =
    { pkgs, ... }:
    let
      msg = command: "noctalia msg ${command}";
      mediaBind = flags: command: {
        cmd = msg command;
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
              hyprland.lua = "hs.dsp.focus({ workspace = ${toString i} })";
              niri.action.focus-workspace = i;
            };
            "SUPER + SHIFT + ${toString i}" = {
              hyprland.lua = "hs.dsp.window.move({ workspace = ${toString i}, follow = false })";
              niri.action.move-column-to-workspace = i;
            };
          }) (lib.range 1 9)
        )
        // {
          "SUPER + q" = {
            hyprland.dsp."window.close" = { };
            niri.action.close-window = { };
          };
          "SUPER + m" = {
            hyprland.cmd = "uwsm stop";
            niri.action.quit.skip-confirmation = true;
          };
          "SUPER + v".cmd = msg "panel-toggle clipboard";
          "SUPER + f" = {
            hyprland.dsp."window.fullscreen" = { };
            niri.action.fullscreen-window = { };
          };
          "SUPER + SHIFT + f" = {
            hyprland.dsp."window.float".action = "toggle";
            niri.action.toggle-window-floating = { };
          };
          "SUPER + Tab" = {
            hyprland.lua = ''hs.dsp.focus({ workspace = "r+1" })'';
            niri.action.focus-workspace-down = { };
          };
          "SUPER + SHIFT + Tab" = {
            hyprland.lua = ''hs.dsp.focus({ workspace = "r-1" })'';
            niri.action.focus-workspace-up = { };
          };

          "SUPER + mouse_down" = {
            hyprland.dsp."window.cycle_next" = { };
            niri.action.focus-column-right = { };
          };
          "SUPER + mouse_up" = {
            hyprland.dsp."window.cycle_next" = {
              next = false;
            };
            niri.action.focus-column-left = { };
          };
          "SUPER + SHIFT + mouse_down" = {
            hyprland.lua = ''hs.dsp.focus({ workspace = "r+1" })'';
            niri.action.focus-workspace-down = { };
          };
          "SUPER + SHIFT + mouse_up" = {
            hyprland.lua = ''hs.dsp.focus({ workspace = "r-1" })'';
            niri.action.focus-workspace-up = { };
          };

          "Print".cmd = msg "screenshot-region";
          "SUPER + p".cmd = msg "screenshot-region";

          "SUPER + i".cmd = "${lib.getExe pkgs.hyprpicker} -a";

          "SUPER + e".cmd = msg "panel-toggle launcher";

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
