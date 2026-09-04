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
          settings.sleep-idle-seconds = 30;
          settings.models-preset = pkgs.writeText "llama-models.ini" (
            lib.generators.toINI { } {
              "*" = {
                gpu-layers = "all";
                gpu-layers-draft = "all";
              };
              "qwen3.8-27b" = {
                hf = "unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL";
                no-mmproj = true;
                split-mode = "none";
                flash-attn = "on";
                ctx-size = 262144;
                cache-type-k = "q4_0";
                cache-type-v = "q4_0";
                cache-type-k-draft = "q4_0";
                cache-type-v-draft = "q4_0";
                batch-size = 512;
                parallel = 1;
                no-cont-batching = true;
                fit = "off";
                spec-type = "draft-mtp";
                spec-draft-n-max = 2;
                reasoning-preserve = true;
                reasoning-format = "deepseek";
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
