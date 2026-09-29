{
  flake.aspects.noctalia.homeManager = {
    programs.noctalia.settings.widget = {
      tray.drawer = true;

      clock = {
        anchor = true;
        format = "{:%B %-d, %Y} {:%H:%M}";
      };

      volume.show_label = false;
      network.show_label = false;
      bluetooth.show_label = false;
      battery.show_label = false;
    };
  };
}
