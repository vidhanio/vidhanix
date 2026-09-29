{
  flake.aspects.noctalia.homeManager =
    { config, ... }:
    {
      programs.noctalia.settings.bar.main = {
        position = "top";
        thickness = 40;
        background_opacity = 1.0;
        shadow = false;
        capsule = false;

        margin_edge = 0;
        margin_ends = 0;
        padding = config.stylix.padding;
        widget_spacing = 10;
        radius = config.stylix.cornerRadius;
        capsule_radius = config.stylix.cornerRadius;

        start = [
          "tray"
          "workspaces"
        ];
        center = [
          "clock"
          "notifications"
        ];
        end = [
          "volume"
          "network"
          "bluetooth"
          "battery"
        ];
      };
    };
}
