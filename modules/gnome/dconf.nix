{ lib, ... }:
{
  flake.modules.nixos.default = {
    programs.dconf = {
      enable = true;
      profiles =
        with lib.gvariant;
        let
          mkDatabases = settings: {
            databases = [
              { inherit settings; }
            ];
          };
        in
        lib.mapAttrs (_: mkDatabases) {
          user = {
            "org/gnome/desktop/wm/keybindings" = {
              switch-applications = mkEmptyArray type.string;
              switch-applications-backward = mkEmptyArray type.string;
            };

            "org/gnome/desktop/peripherals/mouse" = {
              accel-profile = "flat";
            };

            "org/gtk/gtk4/settings/file-chooser" = {
              show-hidden = true;
            };

            "org/gnome/nautilus/preferences" = {
              default-folder-viewer = "icon-view";
              recursive-search = "always";
              search-filter-time-type = "last_modified";
              show-directory-item-counts = "always";
              show-image-thumbnails = "always";
            };

            "org/gnome/mutter" = {
              experimental-features = [
                "variable-refresh-rate"
                "scale-monitor-framebuffer"
              ];
            };
          };
          gdm = {
            "org/gnome/desktop/peripherals/mouse" = {
              accel-profile = "flat";
            };
          };
        };
    };
  };
}
