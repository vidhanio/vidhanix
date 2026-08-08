{ inputs, ... }:
{
  flake-file.inputs.prime-agent = {
    url = "github:PrimeIntellect-ai/prime-agent";
    flake = false;
  };

  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.prime-agent = {
        enable = true;
        package = inputs'.llm-agents.packages.prime-agent.overrideAttrs (old: {
          src = inputs.prime-agent;
          version = "unstable-git";
          # The npm deps are fetched from `src` in a separate derivation;
          # override it as well, or the stale v0.7.0 tag fetch is used.
          npmDeps = old.npmDeps.overrideAttrs (_deps: {
            src = inputs.prime-agent;
          });
          # The binary reports its own version (e.g. 0.7.1), which cannot
          # match `unstable-git`. Keep the python import checks
          # (postInstallCheck) but drop the version regex hooks.
          nativeInstallCheckInputs = [ ];
        });

        settings = {
          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4-flash";
          # Effectively unlimited (no sentinel exists; 0 would disable
          # recursion entirely). Subagents inherit this value.
          rlmMaxDepth = 1024;
        };
      };

      persist.directories = [ ".prime/agent" ];
    };
}
