{
  flake.aspects.hyprland = {
    homeManager = {
      binds = {
        "SUPER + mouse:272" = {
          hyprland.dsp."window.drag" = { };
          hyprland.flags.mouse = true;
          niri.enable = false;
        };
        "SUPER + mouse:273" = {
          hyprland.dsp."window.resize" = { };
          hyprland.flags.mouse = true;
          niri.enable = false;
        };
      };
    };
  };
}
