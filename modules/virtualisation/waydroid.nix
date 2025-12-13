{
  virtualisation.waydroid.enable = true;
  networking.nftables.enable = true;

  persist.directories = [ "/var/lib/waydroid" ];

  home-manager.sharedModules = [
    {
      persist.directories = [ ".local/share/waydroid" ];
    }
  ];
}
