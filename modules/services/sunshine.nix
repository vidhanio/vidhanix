{
  flake.modules = {
    nixos.default = {
      services.sunshine = {
        enable = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    };
    homeManager.default = {
      persist.directories = [ ".config/sunshine" ];
    };
  };
}
