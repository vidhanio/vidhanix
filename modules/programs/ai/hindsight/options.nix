{ lib, ... }:
{
  flake.modules.homeManager.default =
    { self', ... }:
    {
      options.programs.ai.hindsight = {
        enable = lib.mkEnableOption "the Hindsight agent memory server";

        package = lib.mkOption {
          type = lib.types.package;
          default = self'.packages.hindsight;
          defaultText = lib.literalExpression "self'.packages.hindsight";
          description = "The hindsight package to use.";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = ''
            Address the API binds to ({env}`HINDSIGHT_API_HOST`).

            Defaults to loopback: the server is meant for this machine's
            agents, not the network.
          '';
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 8888;
          description = "Port the API listens on ({env}`HINDSIGHT_API_PORT`).";
        };

        logLevel = lib.mkOption {
          type = lib.types.enum [
            "debug"
            "info"
            "warning"
            "error"
          ];
          default = "info";
          description = "Log level ({env}`HINDSIGHT_API_LOG_LEVEL`).";
        };

        database = {
          backend = lib.mkOption {
            type = lib.types.enum [
              "postgresql"
              "oracle"
            ];
            default = "postgresql";
            description = "Database backend ({env}`HINDSIGHT_API_DATABASE_BACKEND`).";
          };

          url = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "postgresql:///hindsight?host=/run/postgresql";
            description = ''
              PostgreSQL connection string ({env}`HINDSIGHT_API_DATABASE_URL`).

              The upstream default is an embedded `pg0` database, which this
              package does not ship; set this to an existing PostgreSQL 14+
              database with the `vector` extension available. The server
              installs the extension and runs its migrations at startup.
            '';
          };

          schema = lib.mkOption {
            type = lib.types.str;
            default = "public";
            description = "PostgreSQL schema for the tables ({env}`HINDSIGHT_API_DATABASE_SCHEMA`).";
          };
        };

        llm = {
          provider = lib.mkOption {
            type = lib.types.enum [
              "openai"
              "openai-responses"
              "openai-codex"
              "claude-code"
              "anthropic"
              "gemini"
              "groq"
              "minimax"
              "deepseek"
              "zai"
              "opencode-go"
              "nous"
              "xai-oauth"
              "fireworks"
              "ollama"
              "ollama-cloud"
              "lmstudio"
              "llamacpp"
              "vertexai"
              "bedrock"
              "litellm"
              "litellmrouter"
              "volcano"
              "openrouter"
              "requesty"
              "none"
            ];
            default = "openai";
            description = "LLM provider ({env}`HINDSIGHT_API_LLM_PROVIDER`).";
          };

          apiKey = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              LLM provider API key ({env}`HINDSIGHT_API_LLM_API_KEY`).

              Prefer {option}`programs.ai.hindsight.service.environmentFiles`
              with a sops template so the key never lands in the Nix store.
            '';
          };

          model = lib.mkOption {
            type = lib.types.str;
            default = "gpt-5-mini";
            description = "Model name ({env}`HINDSIGHT_API_LLM_MODEL`).";
          };

          baseUrl = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "https://opencode.ai/zen/go/v1";
            description = ''
              Custom or OpenAI-compatible endpoint
              ({env}`HINDSIGHT_API_LLM_BASE_URL`). Most providers have a
              built-in default.
            '';
          };

          maxConcurrent = lib.mkOption {
            type = lib.types.int;
            default = 32;
            description = "Max concurrent LLM requests ({env}`HINDSIGHT_API_LLM_MAX_CONCURRENT`).";
          };

          timeout = lib.mkOption {
            type = lib.types.int;
            default = 120;
            description = "Request timeout in seconds ({env}`HINDSIGHT_API_LLM_TIMEOUT`).";
          };

          reasoningEffort = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "max";
            description = ''
              Reasoning effort sent verbatim, e.g. `none`, `low`, `high`
              ({env}`HINDSIGHT_API_LLM_REASONING_EFFORT`).
            '';
          };
        };

        embeddings = {
          provider = lib.mkOption {
            type = lib.types.enum [
              "local"
              "onnx"
              "tei"
              "openai"
              "openai-codex"
              "openrouter"
              "requesty"
              "cohere"
              "google"
              "zeroentropy"
              "litellm"
              "litellm-sdk"
            ];
            default = "onnx";
            description = ''
              Embeddings provider ({env}`HINDSIGHT_API_EMBEDDINGS_PROVIDER`).

              The upstream default `local` needs the `local-ml` extra
              (sentence-transformers + torch), which this package does not
              ship; `onnx` is the packaged in-process alternative.
            '';
          };

          onnxModelId = lib.mkOption {
            type = lib.types.str;
            default = "intfloat/multilingual-e5-small";
            description = ''
              Hugging Face repo for the ONNX embedding model, downloaded on
              first use ({env}`HINDSIGHT_API_EMBEDDINGS_ONNX_MODEL_ID`).
            '';
          };
        };

        reranker = {
          provider = lib.mkOption {
            type = lib.types.enum [
              "local"
              "tei"
              "cohere"
              "openrouter"
              "zeroentropy"
              "siliconflow"
              "alibaba"
              "google"
              "flashrank"
              "litellm"
              "litellm-sdk"
              "jina-mlx"
              "rrf"
            ];
            default = "rrf";
            description = ''
              Reranker provider ({env}`HINDSIGHT_API_RERANKER_PROVIDER`).

              `rrf` is a model-free fusion of the retrieval arms; the `local`
              default needs the un-packaged `local-ml` extra.
            '';
          };
        };

        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          example = {
            HINDSIGHT_API_WORKER_MAX_SLOTS = 20;
            retain_extraction_mode = "verbatim";
            LLM_EXTRA_BODY = {
              thinking = {
                type = "enabled";
              };
            };
          };
          description = ''
            Extra Hindsight settings, written to the generated environment
            file. Keys are either full environment variable names
            (`HINDSIGHT_API_*`, `HINDSIGHT_CP_*`) or snake_case field names
            (`llm_provider`, `database_url`), which get the `HINDSIGHT_API_`
            prefix and upper-casing, mirroring the server's own config
            normalization. Scalar values are written verbatim; attrsets and
            lists are JSON-encoded (for `*_EXTRA_BODY` and friends). `null`
            omits the variable. These override the typed options above.
          '';
        };

        service = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to install the `hindsight` systemd user service.";
          };

          environmentFiles = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            default = [ ];
            description = ''
              Extra environment files read after the generated one, so they
              take precedence — use them for secrets via sops templates,
              e.g. `HINDSIGHT_API_LLM_API_KEY`.
            '';
          };
        };
      };
    };
}
