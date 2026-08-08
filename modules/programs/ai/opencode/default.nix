_: {
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.opencode = {
        enable = true;
        # OpenCode 1 CLI from llm-agents.nix (prebuilt release binary from
        # github.com/anomalyco/opencode, the npm `latest` channel). Installs
        # as `opencode`, distinct from the `opencode2` V2 preview.
        #
        # The `programs.opencode` options (settings, tui, context, themes,
        # agents, commands, skills, tools) come from Home Manager's own
        # modules/programs/opencode.nix, which writes the same
        # `$XDG_CONFIG_HOME/opencode` files that OpenCode 2 reads.
        package = inputs'.llm-agents.packages.opencode;

        settings = {
          # Same model as prime-agent (modules/programs/ai/prime-agent/
          # default.nix): provider `opencode-go`, model `deepseek-v4-flash`.
          # `opencode-go/deepseek-v4-flash` is a built-in catalog model
          # (models.dev), shared by OpenCode 1 and 2.
          model = "opencode-go/deepseek-v4-flash";
          # The binary is managed by Nix, so it must not update itself.
          autoupdate = false;
        };
      };

      # No `persist.directories` here: OpenCode 1 and 2 share the same XDG
      # directories (.config/opencode, .local/share/opencode,
      # .local/state/opencode), which the opencode2 module already persists,
      # and the impermanence assertion forbids duplicate entries.
    };
}
