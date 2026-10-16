{ lib, ... }:
{
  profiles.pc.homeModule = {
    services.easyeffects = {
      enable = true;
      preset.input = "aec-low";
      extraPresets.aec-low = lib.importJSON ./aec-low.json;
      settings = {
        EffectsPipelines.processAllOutputs = false;
        StreamInputs.inputDevice = null;
        StreamOutputs.outputDevice = null;
      };
    };
  };
}
