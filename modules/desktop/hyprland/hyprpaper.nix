{
  flake.modules.homeManager.default = {
    services.hyprpaper = {
      enable = true;
      settings.splash = false;
    };
  };
}
