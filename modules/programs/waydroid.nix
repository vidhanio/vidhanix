{
  flake.modules = {
    nixos.default = {
      virtualisation.waydroid.enable = true;
      networking.nftables.enable = true;
      persist.directories = [ "/var/lib/waydroid" ];
    };
    homeManager.default = {
      persist.directories = [ ".local/share/waydroid" ];
    };
  };
}
