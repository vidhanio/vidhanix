{ lib, ... }:
{
  perSystem =
    { pkgs, config, ... }:
    {
      apps.generate-files.program = pkgs.writeShellApplication {
        name = "generate-files";
        text = ''
          # files
          ${lib.getExe config.files.writer.drv}

          # flake-file
          ${lib.getExe config.packages.write-flake}
        '';
      };
    };
}
