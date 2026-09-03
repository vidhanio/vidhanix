{
  flake.aspects.stylix = {
    nixos = {
      stylix.opacity = {
        popups = 0.9;
        desktop = 0.9;
        terminal = 0.9;
      };
    };
  };
}
