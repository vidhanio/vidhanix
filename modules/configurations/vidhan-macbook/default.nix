{ config, ... }:
{
  configurations.vidhan-macbook = {
    facterReportPath = ./facter.json;
    stateVersion = "26.05";
    module = {
      imports = with config.flake.modules.nixos; [ macbook ];
    };
  };
}
