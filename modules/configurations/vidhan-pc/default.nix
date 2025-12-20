{ config, ... }:
{
  configurations.vidhan-pc = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    module = {
      imports = with config.flake.modules.nixos; [ desktop ];
    };
  };
}
