{ inputs, ... }:
{
  flake-file.inputs.prime-agent = {
    url = "github:PrimeIntellect-ai/prime-agent";
    flake = false;
  };

  flake.modules.homeManager.default =
    { inputs', ... }:
    let
      pkg = inputs'.llm-agents.packages.prime-agent.overrideAttrs (old: {
        src = inputs.prime-agent;
        version = "unstable-git";
        # npmDeps must follow src (stale v0.7.0 fetch otherwise).
        npmDeps = old.npmDeps.overrideAttrs (_deps: {
          src = inputs.prime-agent;
        });
        nativeInstallCheckInputs = [ ];
      });
    in
    {
      programs.prime-agent = {
        enable = true;
        enableMcpIntegration = true;

        package = pkg;

        settings = {
          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4-flash";
          rlmMaxDepth = 2;
          defaultThinkingLevel = "max";
        };
      };

      persist.directories = [ ".prime/agent" ];
    };
}
