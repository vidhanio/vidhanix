{
  flake.aspects.run0 = {
    nixos = {
      security.sudo.enable = false;

      security.run0 = {
        enable = true;
        wheelNeedsPassword = false;
        sudo-shim.enable = true;
      };
    };
  };
}
