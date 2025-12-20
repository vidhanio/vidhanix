{ config, ... }:
{
  configurations.vidhan-macbook = {
    system = "aarch64-linux";
    stateVersion = "26.05";
    module = {
      imports = with config.flake.modules.nixos; [ macbook ];
    };
  };
}
