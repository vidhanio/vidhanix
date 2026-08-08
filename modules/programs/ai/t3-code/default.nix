{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.t3-code = {
        enable = true;
        # T3 Code server (the `t3` CLI) from llm-agents.nix. The wrapper adds
        # the provider CLIs (claude-code, codex, cursor-agent, grok, opencode)
        # to PATH, so the `opencode` binary is found without extra setup.
        package = inputs'.llm-agents.packages.t3code;

        # Electron desktop app ("T3 Code (Alpha)"). Shares the same data
        # directory (`~/.t3`) and embedded server as the CLI.
        desktop = {
          enable = true;
          package = inputs'.llm-agents.packages.t3code-desktop;
        };

        settings = {
          # The provider CLIs are Nix-managed, so T3 Code must not check them
          # for updates. (The server itself never self-updates: `t3 service
          # update` is an explicit, opt-in action.)
          enableProviderUpdateChecks = false;

          # Same model as prime-agent (modules/programs/ai/prime-agent/
          # default.nix): provider `opencode-go`, model `deepseek-v4-flash`.
          # `opencode-go/deepseek-v4-flash` is a built-in catalog model and
          # matches the `provider/model` slug format T3 Code passes to the
          # OpenCode SDK.
          textGenerationModelSelection = {
            instanceId = "opencode";
            model = "opencode-go/deepseek-v4-flash";
          };

          providers.opencode = {
            # `opencode` is on PATH via the llm-agents wrapper; the default
            # binary path already resolves it. Mark the provider enabled so a
            # fresh settings file starts with OpenCode available.
            enabled = true;
          };
        };
      };

      persist.directories = [ ".t3" ];
    };
}
