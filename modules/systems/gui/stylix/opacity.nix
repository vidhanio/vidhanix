{
  flake.aspects.stylix = {
    nixos = {
      stylix.opacity = {
        applications = 0.75;
        popups = 0.75;
        desktop = 0.75;
        terminal = 0.75;
      };
    };
  };
}
