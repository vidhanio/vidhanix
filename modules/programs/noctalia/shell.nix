{ lib, ... }: {
  profiles.pc.homeModule =
    { config, ... }:
    {
      programs.noctalia = {
        customPalettes.stylix.dark.mSurface = lib.mkForce config.lib.stylix.colors.withHashtag.base00;

        settings.shell = {
          # Noctalia's scale multiplies its 12px base radius; it is not pixels.
          corner_radius_scale = config.stylix.cornerRadius / 12.0;
          polkit_agent = true;
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
          launch_apps_as_systemd_services = true;
          screenshot.save_to_file = false;
          setup_wizard_enabled = false;
          external_ip_enabled = true;
        };
      };
    };
}
