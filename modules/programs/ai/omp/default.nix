{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.omp = {
        enable = true;
        # Oh My Pi from llm-agents.nix (Bun build + Rust pi-natives addon).
        package = inputs'.llm-agents.packages.omp;

        settings = {
          # The binary is managed by Nix, so it must not check for updates.
          startup.checkUpdate = false;
          # The repo's fonts are nerd-patched (modules/systems/gui/fonts).
          symbolPreset = "nerd";

          # Same model as prime-agent (modules/programs/ai/prime-agent/
          # default.nix): provider `opencode-go`, model `deepseek-v4-flash`.
          # `opencode-go/deepseek-v4-flash` is a built-in catalog model.
          modelRoles.default = "opencode-go/deepseek-v4-flash";
          # prime-agent's rlmMaxDepth = 1024, mirrored here. -1 = unlimited
          # (omp's `task.maxRecursionDepth` accepts -1; prime-agent does not).
          task.maxRecursionDepth = -1;
        };
      };

      persist.directories = [ ".omp" ];
    };
}
