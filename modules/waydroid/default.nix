{
  flake.modules = {
    nixos.default = {
      virtualisation.waydroid.enable = true;
      networking.nftables.enable = true;
    };
  };
}
