{
  flake-file.inputs.llama-cpp.url = "github:PrismML-Eng/llama.cpp";

  flake.aspects.llama = {
    nixos =
      {
        lib,
        pkgs,
        inputs',
        ...
      }:
      {
        services.llama-cpp = {
          enable = true;
          package = inputs'.llama-cpp.packages.rocm.override { rocmGpuTargets = "gfx1200"; };
          settings.sleep-idle-seconds = 30;
          settings.models-preset = pkgs.writeText "llama-models.ini" (
            lib.generators.toINI { } {
              "*" = {
                gpu-layers = "all";
                gpu-layers-draft = "all";
              };
              "bonsai-2-27b" = {
                hf = "prism-ml/Ternary-Bonsai-2-27B-gguf:PQ2_0";
                ctx-size = 220000;
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
                ctx-size = 49152;
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
}
