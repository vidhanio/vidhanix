{
  flake.modules = {
    nixos.default = _: {
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
