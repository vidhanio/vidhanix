{
  flake.modules.nixos.default = {
    services.sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    persist.directories = [ ".config/sunshine" ];
  };
}
