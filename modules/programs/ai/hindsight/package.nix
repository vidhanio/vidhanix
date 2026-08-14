let
  hindsight-api-slim =
    {
      lib,
      fetchFromGitHub,
      python3Packages,
      nix-update-script,
    }:
    python3Packages.buildPythonPackage (finalAttrs: {
      pname = "hindsight-api-slim";
      version = "0.9.1";

      src = fetchFromGitHub {
        owner = "vectorize-io";
        repo = "hindsight";
        tag = "v${finalAttrs.version}";
        hash = "sha256-MjsWNIOPvTBf6q/fhMJquomIM6Vvyik7T2Pnn9P+qLw=";
      };

      pyproject = true;

      # The repo is a uv workspace; the server package lives in its own
      # subdirectory with the real pyproject.toml.
      sourceRoot = "source/hindsight-api-slim";

      build-system = with python3Packages; [
        hatchling
      ];

      dependencies = with python3Packages; [
        aiohttp
        alembic
        anthropic
        asyncpg
        authlib
        boto3
        claude-agent-sdk
        cohere
        croniter
        cryptography
        dateparser
        fastapi
        fastmcp
        filelock
        google-auth
        google-genai
        greenlet
        httpx
        json-repair
        langchain-core
        langchain-text-splitters
        langsmith
        litellm
        markitdown
        obstore
        openai
        opentelemetry-api
        opentelemetry-exporter-otlp-proto-http
        opentelemetry-exporter-prometheus
        opentelemetry-instrumentation-fastapi
        opentelemetry-sdk
        opentelemetry-semantic-conventions
        orjson
        pgvector
        pillow
        protobuf
        psycopg2-binary
        pyasn1
        pydantic
        pygments
        pyjwt
        python-dateutil
        python-dotenv
        python-multipart
        rich
        sqlalchemy
        tiktoken
        tornado
        typer
        urllib3
        uvicorn
        uvloop
        wsproto
      ];

      # The test suite needs a live PostgreSQL and an LLM provider.
      doCheck = false;

      # The upstream `>=` floors for the opentelemetry-* trio (sdk 1.44,
      # semantic-conventions 0.65b0, exporter 0.65b0) are pip-resolution
      # guards; nixpkgs ships a coherent older set, so the runtime-deps
      # checker's version complaints are noise.
      dontCheckRuntimeDeps = true;

      pythonImportsCheck = [ "hindsight_api" ];

      passthru.optional-dependencies = {
        # Upstream also ships `local-ml` (sentence-transformers + torch, needs
        # flashrank) and `embedded-db` (pg0-embedded); neither is fully packaged
        # in nixpkgs, so they are omitted here.
        local-llm = with python3Packages; [
          huggingface-hub
          llama-cpp-python
        ];
        local-onnx = with python3Packages; [
          huggingface-hub
          numpy
          onnxruntime
          tokenizers
          transformers
        ];
        oracle = with python3Packages; [
          oracledb
        ];
      };

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Hindsight agent memory server (slim variant)";
        homepage = "https://github.com/vectorize-io/hindsight";
        changelog = "https://github.com/vectorize-io/hindsight/releases/tag/${finalAttrs.src.tag}";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
        mainProgram = "hindsight-api";
      };
    });

  hindsight =
    {
      python3Packages,
      hindsight-api-slim,
    }:
    python3Packages.toPythonApplication (
      hindsight-api-slim.overridePythonAttrs (oldAttrs: {
        pname = "hindsight";
        dependencies =
          oldAttrs.dependencies ++ hindsight-api-slim.passthru.optional-dependencies.local-onnx;
      })
    );
in
{
  perSystem =
    { pkgs, ... }:
    let
      slim = pkgs.callPackage hindsight-api-slim { };
    in
    {
      packages = {
        hindsight-api-slim = slim;
        hindsight = pkgs.callPackage hindsight { hindsight-api-slim = slim; };
      };
    };
}
