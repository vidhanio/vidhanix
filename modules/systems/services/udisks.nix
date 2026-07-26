{ lib, ... }:
{
  den.default = {
    nixos = {
      services.udisks2.enable = true;
    };
    homeManager =
      { pkgs, ... }:
      {
        services.udiskie = {
          enable = true;
          settings.program_options.file_manager = lib.getExe pkgs.nautilus;
        };
      };
  };
}
