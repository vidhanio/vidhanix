{
  flake.aspects.stylix = {
    nixos = {
      stylix.opacity = {
        applications = 0.5;
        popups = 0.5;
        desktop = 0.5;
        terminal = 0.5;
      };
    };
  };
}
