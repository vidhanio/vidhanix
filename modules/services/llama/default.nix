{
  hosts.vortex = {
    module =
      {
        lib,
        pkgs,
        inputs',
        ...
      }:
      {
        services.llama-cpp = {
          enable = true;
          package = inputs'.llama-cpp.packages.vulkan;
          settings = {
            sleep-idle-seconds = 30;
            models-max = 1;
            models-preset = pkgs.writeText "llama-models.ini" (
              lib.generators.toINI { } {
                "*" = {
                  gpu-layers = "all";
                  gpu-layers-draft = "all";
                };
                "lfm3-1.7b" = {
                  hf = "LiquidAI/LFM3-1.7B-GGUF:Q4_0";
                  device = "Vulkan0";
                  split-mode = "none";
                  ctx-size = 262144;
                  batch-size = 512;
                  ubatch-size = 512;
                  parallel = 1;
                  flash-attn = "on";
                  cache-type-k = "q8_0";
                  cache-type-v = "q8_0";
                  jinja = true;
                  reasoning = "on";
                  reasoning-format = "deepseek";
                  reasoning-preserve = false;
                  temp = 0.1;
                  top-p = 1.0;
                  top-k = 50;
                  min-p = 0.0;
                  repeat-penalty = 1.1;
                };
                "lfm3-vl-2b" = {
                  hf = "LiquidAI/LFM3-VL-2B-GGUF:Q4_0";
                  device = "Vulkan0";
                  split-mode = "none";
                  ctx-size = 131072;
                  batch-size = 512;
                  ubatch-size = 512;
                  parallel = 1;
                  flash-attn = "on";
                  cache-type-k = "q8_0";
                  cache-type-v = "q8_0";
                  jinja = true;
                  reasoning = "on";
                  reasoning-format = "deepseek";
                  reasoning-preserve = false;
                  temp = 0.1;
                  top-p = 1.0;
                  top-k = 50;
                  min-p = 0.0;
                  repeat-penalty = 1.1;
                };
                "lfm3-omni-2b" = {
                  hf = "LiquidAI/LFM3-Omni-2B-GGUF:Q4_K_M";
                  device = "Vulkan0";
                  split-mode = "none";
                  ctx-size = 32768;
                  batch-size = 512;
                  ubatch-size = 512;
                  parallel = 1;
                  flash-attn = "on";
                  jinja = true;
                  reasoning = "off";
                  temp = 0.1;
                  top-k = 50;
                  min-p = 0.0;
                  repeat-penalty = 1.1;
                };
                "bonsai-2-27b" = {
                  hf = "prism-ml/Ternary-Bonsai-2-27B-gguf:PQ2_0";
                  ctx-size = 262144;
                  batch-size = 512;
                  flash-attn = "on";
                  parallel = 1;
                  image-max-tokens = 1024;
                  cache-type-k = "q4_0";
                  cache-type-v = "q4_0";
                  temp = 1.0;
                  top-k = 20;
                  min-p = 0.0;
                  reasoning = "on";
                };
                "qwen3.8-27b-byteshape" = {
                  hf = "byteshape/Qwen3.8-27B-GGUF:Qwen3.8-27B-IQ3_XS-3.01bpw";
                  no-mmproj = true;
                  split-mode = "none";
                  fit = "off";
                  ctx-size = 131072;
                  batch-size = 512;
                  parallel = 1;
                  flash-attn = "on";
                  cache-type-k = "q4_0";
                  cache-type-v = "q4_0";
                  spec-type = "draft-mtp";
                  spec-draft-n-max = 3;
                  reasoning-format = "deepseek";
                  reasoning-preserve = true;
                  temp = 1.0;
                  top-k = 20;
                  min-p = 0.0;
                };
              }
            );
          };
        };
      };
  };
}
