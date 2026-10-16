{ lib, ... }:
{
  profiles.pc.homeModule = {
    services.easyeffects = {
      enable = true;
      preset.input = "aec-only";
      extraPresets.aec-only = lib.importJSON ./aec-only.json;
      settings = {
        EffectsPipelines.processAllOutputs = false;
        StreamInputs.inputDevice = null;
        StreamOutputs.outputDevice = null;
      };
    };
  };
}
