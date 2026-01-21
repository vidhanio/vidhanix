{ lib, ... }:
{
  flake.modules.homeManager.default =
    { osConfig, ... }:
    {
      programs.opencode.settings.provider.ollama = lib.mkIf osConfig.services.ollama.enable {
        name = "Ollama";
        npm = "@ai-sdk/openai-compatible";
        options.baseURL = "http://${osConfig.services.ollama.host}:${toString osConfig.services.ollama.port}/v1";
        models = lib.genAttrs osConfig.services.ollama.loadModels (_: {
          tools = true;
          reasoning = true;
        });
      };
    };

  configurations.vidhan-pc = {
    module =
      { pkgs, ... }:
      {
        services = {
          ollama = {
            enable = true;
            package = pkgs.ollama-rocm;
            environmentVariables = {
              OLLAMA_CONTEXT_LENGTH = "16384";
            };
            loadModels = [
              "qwen3-coder:30b"
            ];
            syncModels = true;
          };
        };

        persist.directories = [ "/var/lib/private/ollama" ];
      };
  };
}
