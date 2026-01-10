{ config, ... }:
{
  configurations.vidhan-pc = {
    facterReportPath = ./facter.json;
    stateVersion = "26.05";
    module = {
      imports = with config.flake.modules.nixos; [ desktop ];
    };
  };
}
