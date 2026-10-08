{
  profiles.pc.homeModule = {
    programs.noctalia.settings.widget = {
      tray.drawer = true;
      workspaces.style = "minimal";

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
