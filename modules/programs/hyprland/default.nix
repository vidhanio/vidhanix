{
  profiles.pc = {
    module =
      { inputs', ... }:
      {
        programs.hyprland = {
          enable = true;
          package = inputs'.hyprland.packages.hyprland;
          portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
        };
      };

    homeModule =
      {
        config,
        inputs',
        ...
      }:
      {
        home.file.".profile".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        wayland.windowManager.hyprland = {
          enable = true;

          package = inputs'.hyprland.packages.hyprland;
          portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;

          systemd = {
            enableXdgAutostart = true;

            # Import the login environment before starting the target.
            variables = [ "--all" ];
          };

          xdph.settings.screencopy.allow_token_by_default = true;
          settings.config = {
            ecosystem = {
              no_update_news = true;
              no_donation_nag = true;
            };
            misc.disable_splash_rendering = true;
            xwayland.force_zero_scaling = true;
          };

          # Home Manager's hook owns the target; don't let Hyprland start it
          # before the full login environment is imported.
          extraConfig = ''hl.env("HYPRLAND_NO_SD_TARGET", "1")'';
        };
      };
  };
}
