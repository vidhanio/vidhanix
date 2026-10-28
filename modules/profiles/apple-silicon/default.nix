{ config, inputs, ... }:
{
  profiles.apple-silicon = {
    module = {
      imports = [
        config.profiles.pc.module
        inputs.nixos-apple-silicon.nixosModules.default
      ];
      hardware.asahi.enable = true;
    };
    homeModule.imports = [ config.profiles.pc.homeModule ];
  };
}
