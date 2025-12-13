{
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  home-manager.sharedModules = [
    {
      persist.directories = [ ".config/sunshine" ];
    }
  ];
}
