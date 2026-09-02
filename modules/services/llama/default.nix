{
  flake.aspects.llama = {
    nixos =
      {
        lib,
        pkgs,
        ...
      }:
      {
        services.llama-cpp = {
          enable = true;
          package = pkgs.llama-cpp-vulkan;
          settings.models-preset = pkgs.writeText "llama-models.ini" (
            lib.generators.toINI { } {
              "qwen3.8-27b" = {
                hf = "unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL";
                alias = "qwen3.8-27b";
                no-mmproj = true;
                gpu-layers = "all";
                gpu-layers-draft = "all";
                split-mode = "none";
                flash-attn = "on";
                ctx-size = 262144;
                cache-type-k = "q4_0";
                cache-type-v = "q4_0";
                cache-type-k-draft = "q4_0";
                cache-type-v-draft = "q4_0";
                batch-size = 512;
                ubatch-size = 512;
                parallel = 1;
                no-cont-batching = true;
                fit = "off";
                spec-type = "draft-mtp";
                spec-draft-n-max = 2;
                spec-draft-p-min = 0;
                jinja = true;
                reasoning = "auto";
                reasoning-preserve = true;
                reasoning-format = "deepseek";
                temp = 1.0;
                top-p = 0.95;
                top-k = 20;
                min-p = 0.0;
                presence-penalty = 0.0;
                repeat-penalty = 1.0;
              };
            }
          );
        };
      };
  };
}
