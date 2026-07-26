{
  den.default = {
    nixos = {
      virtualisation.waydroid.enable = true;
      networking.nftables.enable = true;
      persist.directories = [ "/var/lib/waydroid" ];
    };
    homeManager = {
      persist.directories = [ ".local/share/waydroid" ];
    };
  };
}
