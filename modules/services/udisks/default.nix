{ lib, ... }:
{
  profiles.pc = {
    module = {
      services.udisks2 = {
        enable = true;
        mountOnMedia = true;
      };
    };
    homeModule =
      { pkgs, ... }:
      {
        services.udiskie = {
          enable = true;
          settings.program_options.file_manager = lib.getExe pkgs.nautilus;
        };
      };
  };
}
