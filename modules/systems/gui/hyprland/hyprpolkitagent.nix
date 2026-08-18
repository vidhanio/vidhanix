{
  flake.aspects.hyprland = {
    homeManager = {
      services.hyprpolkitagent.enable = true;
    };
  };
}
