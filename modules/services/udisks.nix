{ lib, ... }:
{
  flake.modules = {
    nixos.default = {
      services.udisks2.enable = true;
    };
    homeManager.default =
      { pkgs, ... }:
      {
        services.udiskie = {
          enable = true;
          settings.program_options.file_manager = lib.getExe pkgs.nautilus;
        };
      };
  };
}
