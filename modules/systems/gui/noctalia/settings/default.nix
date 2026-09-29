{
  flake.aspects.noctalia.homeManager = {
    programs.noctalia.settings = {
      lockscreen.enabled = false; # handled by hyprlock
      location.auto_locate = true;
      control_center.sidebar_section = "none";
      dock.enabled = false;
    };
  };
}
