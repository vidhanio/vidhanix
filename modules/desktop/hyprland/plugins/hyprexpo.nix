{ withSystem, ... }:
{
  flake.modules.homeManager.default =
    { config, pkgs, ... }:
    {
      wayland.windowManager.hyprland = {
        plugins = withSystem pkgs.stdenv.hostPlatform.system (
          { inputs', ... }: [ inputs'.hyprland-plugins.packages.hyprexpo ]
        );
        settings = {
          plugin.hyprexpo.bg_col = "rgb(${config.lib.stylix.colors.base03})";
          bind = [
            "SUPER, Tab, hyprexpo:expo, toggle"
          ];
        };
      };
    };
}
