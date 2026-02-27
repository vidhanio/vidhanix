{
  flake.modules = {
    nixos.default =
      { pkgs, ... }:
      {
        services.sunshine = {
          enable = true;
          capSysAdmin = true;
          openFirewall = true;
          package = pkgs.sunshine.override {
            boost = pkgs.boost187;
          };
        };
      };
    homeManager.default = {
      persist.directories = [ ".config/sunshine" ];
    };
  };
}
