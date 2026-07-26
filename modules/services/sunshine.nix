{
  den.default = {
    nixos = _: {
      services.sunshine = {
        enable = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    };
    homeManager = {
      persist.directories = [ ".config/sunshine" ];
    };
  };
}
