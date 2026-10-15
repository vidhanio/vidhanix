{ lib, ... }:
{
  profiles.pc.homeModule =
    { pkgs, ... }:
    let
      screenshot = pkgs.writeShellApplication {
        name = "screenshot-region";
        runtimeInputs = with pkgs; [
          slurp
          grim
          wl-clipboard
        ];
        text = ''
          grim -g "$(slurp)" - | wl-copy --type image/png
        '';
      };
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
      desktop.binds =
        lib.mergeAttrsList (
          map (i: {
            "SUPER + ${toString i}" = {
              hyprland.lua = "hs.dsp.focus({ workspace = ${toString i} })";
              niri.action.focus-workspace = i;
            };
            "SUPER + SHIFT + ${toString i}" = {
              hyprland.lua = "hs.dsp.window.move({ workspace = ${toString i}, follow = false })";
              niri.action.move-column-to-workspace = {
                _args = [ i ];
                _props.focus = false;
              };
            };
          }) (lib.range 1 9)
        )
        // {
          "SUPER + q" = {
            hyprland.dsp."window.close" = { };
            niri.action.close-window = { };
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
            hyprland.lua = ''hs.dsp.focus({ workspace = "m+1" })'';
            niri.action.focus-workspace-down = { };
          };
          "SUPER + SHIFT + Tab" = {
            hyprland.lua = ''hs.dsp.focus({ workspace = "m-1" })'';
            niri.action.focus-workspace-up = { };
          };

          "SUPER + mouse_up" = {
            hyprland.dsp.layout = "move -col";
            niri.action.focus-column-left = { };
          };
          "SUPER + mouse_down" = {
            hyprland.dsp.layout = "move +col";
            niri.action.focus-column-right = { };
          };

          "SUPER + space".cmd = msg "panel-toggle launcher";

          "Print".cmd = lib.getExe screenshot;
          "SUPER + p".cmd = lib.getExe screenshot;

          "SUPER + i".cmd = "${lib.getExe pkgs.hyprpicker} -a";

          "SUPER + e".app = "nautilus";
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
