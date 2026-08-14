_: {
  flake.modules.homeManager.default =
    {
      self',
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.programs.ai.hindsight;

      # Settings are given as full env names or snake_case field names (the
      # server's own normalization); typed options always write their env var.
      toEnvName =
        name:
        if lib.hasPrefix "HINDSIGHT_API_" name || lib.hasPrefix "HINDSIGHT_CP_" name then
          name
        else
          "HINDSIGHT_API_${lib.toUpper name}";

      toEnvValue =
        value:
        if value == null then
          null
        else if lib.isBool value then
          (if value then "true" else "false")
        else if lib.isAttrs value || lib.isList value then
          builtins.toJSON value
        else
          toString value;

      settingsEnv = lib.mapAttrs' (
        name: value: lib.nameValuePair (toEnvName name) (toEnvValue value)
      ) cfg.settings;

      typedEnv = {
        HINDSIGHT_API_HOST = cfg.host;
        HINDSIGHT_API_PORT = cfg.port;
        HINDSIGHT_API_LOG_LEVEL = cfg.logLevel;
        HINDSIGHT_API_DATABASE_BACKEND = cfg.database.backend;
        HINDSIGHT_API_DATABASE_URL = cfg.database.url;
        HINDSIGHT_API_DATABASE_SCHEMA = cfg.database.schema;
        HINDSIGHT_API_LLM_PROVIDER = cfg.llm.provider;
        HINDSIGHT_API_LLM_API_KEY = cfg.llm.apiKey;
        HINDSIGHT_API_LLM_MODEL = cfg.llm.model;
        HINDSIGHT_API_LLM_BASE_URL = cfg.llm.baseUrl;
        HINDSIGHT_API_LLM_MAX_CONCURRENT = cfg.llm.maxConcurrent;
        HINDSIGHT_API_LLM_TIMEOUT = cfg.llm.timeout;
        HINDSIGHT_API_LLM_REASONING_EFFORT = cfg.llm.reasoningEffort;
        HINDSIGHT_API_EMBEDDINGS_PROVIDER = cfg.embeddings.provider;
        HINDSIGHT_API_EMBEDDINGS_ONNX_MODEL_ID = cfg.embeddings.onnxModelId;
        HINDSIGHT_API_RERANKER_PROVIDER = cfg.reranker.provider;
      };

      env = lib.mapAttrs (_: toEnvValue) (
        lib.filterAttrs (_: value: value != null) (typedEnv // settingsEnv)
      );

      # Bare when the value is a safe dotenv token, else double-quoted with
      # backslash escapes (python-dotenv semantics).
      quoteEnvValue =
        value:
        if builtins.match "^[A-Za-z0-9_./:@%+=,-]*$" value == null then
          ''"${builtins.replaceStrings [ "\\" "\"" "\n" ] [ "\\\\" "\\\"" "\\n" ] value}"''
        else
          value;

      envFile = pkgs.writeText "hindsight-env" (
        lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}=${quoteEnvValue value}") env)
        + "\n"
      );
    in
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

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];

        systemd.user.services.hindsight = lib.mkIf cfg.service.enable {
          Unit.Description = "Hindsight agent memory API server";

          Install.WantedBy = [ "default.target" ];

          Service = {
            ExecStart = lib.getExe cfg.package;
            WorkingDirectory = config.home.homeDirectory;
            Environment = [ "PYTHONUNBUFFERED=1" ];
            # The generated env file lives in the (world-readable) store; keep
            # secrets out of the typed options and use `service.environmentFiles`.
            EnvironmentFile = [ envFile ] ++ cfg.service.environmentFiles;
            Restart = "on-failure";
            RestartSec = 5;
            UMask = "0077";
          };
        };

        persist.directories = [
          # Daemon log; pg0 data if the embedded database is ever enabled.
          ".hindsight"
          # ONNX embedding models and tiktoken encodings, downloaded on first use.
          ".cache/huggingface"
        ];
      };
    };
}
