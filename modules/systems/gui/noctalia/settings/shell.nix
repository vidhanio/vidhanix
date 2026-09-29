{ lib, ... }: {
  flake.aspects.noctalia.homeManager =
    { config, ... }:
    {
      programs.noctalia = {
        customPalettes.stylix.dark.mSurface = lib.mkForce config.lib.stylix.colors.withHashtag.base00;

        settings.shell = {
          corner_radius_scale = config.stylix.cornerRadius;
          popup_shadows = false;
          panel = {
            open_near_click_control_center = true;
            shadow = false;
            transparency_mode =
              if config.stylix.opacity.popups == 1.0 then
                "solid"
              else if config.stylix.opacity.popups >= 0.6 then
                "soft"
              else
                "glass";
          };
          screenshot.save_to_file = false;
          launch_apps_custom_command = "uwsm app -- $CMD";
          setup_wizard_enabled = false;
          external_ip_enabled = true;
        };
      };
    };
}
