{
  flake-file = {
    inputs.llm-agents.url = "github:numtide/llm-agents.nix";

    nixConfig = {
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
    };
  };
}
