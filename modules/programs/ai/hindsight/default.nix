_: {
  flake.modules.homeManager.default =
    {
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

      envPath = "${config.home.homeDirectory}/.config/hindsight/env";
    in
    {
      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];

        # home.file links into the store, so it cannot carry a restrictive
        # mode; copy the generated env into a real 0600 file at activation.
        home.activation.hindsightEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          cat ${envFile} > ${envPath}
          chmod 600 ${envPath}
        '';

        systemd.user.services.hindsight = lib.mkIf cfg.service.enable {
          Unit.Description = "Hindsight agent memory API server";

          Install.WantedBy = [ "default.target" ];

          Service = {
            ExecStart = lib.getExe cfg.package;
            WorkingDirectory = config.home.homeDirectory;
            Environment = [ "PYTHONUNBUFFERED=1" ];
            EnvironmentFile = [ envPath ] ++ cfg.service.environmentFiles;
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

  # This machine's wiring: opencode-go (deepseek-v4-flash) as the LLM via the
  # `opencode` sops secret, and a local PostgreSQL with pgvector for storage.
  configurations.vidhan-pc = {
    module =
      { pkgs, ... }:
      {
        services.postgresql = {
          enable = true;
          package = pkgs.postgresql_16.withPackages (ps: [ ps.pgvector ]);
          ensureDatabases = [
            "hindsight"
            "vidhanio"
          ];
          ensureUsers = [
            {
              name = "vidhanio";
              ensureDBOwnership = true;
            }
          ];
        };
      };

    homeModule =
      { config, ... }:
      {
        sops.secrets.opencode = { };

        sops.templates."hindsight-env" = {
          content = ''
            HINDSIGHT_API_LLM_API_KEY=${config.sops.placeholder.opencode}
          '';
        };

        programs.ai.hindsight = {
          enable = true;

          database.url = "postgresql:///hindsight?host=/run/postgresql";

          llm = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
          };

          service.environmentFiles = [ config.sops.templates."hindsight-env".path ];
        };
      };
  };
}
