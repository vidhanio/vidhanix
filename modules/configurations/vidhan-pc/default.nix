{ config, ... }:
{
  configurations.vidhan-pc = {
    facterReportPath = ./facter.json;
    module = {
      imports = with config.flake.modules.nixos; [ desktop ];
      hardware.facter.reportPath = ./facter.json;
      system.stateVersion = "26.05";
    };
  };
}
