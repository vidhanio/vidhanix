{ pkgs, ... }:
{
  flake.modules.homeManager.default = {
    programs.gnome-shell = {
      enable = true;
      extensions =
        with pkgs.gnomeExtensions;
        map (package: { inherit package; }) [
          appindicator
          dash-to-panel
          pip-on-top
          rounded-window-corners-reborn
          steal-my-focus-window
          solaar-extension
        ];
    };
  };
}
