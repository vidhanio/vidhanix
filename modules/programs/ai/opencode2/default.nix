_: {
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.opencode2 = {
        enable = true;
        # OpenCode 2 preview CLI from llm-agents.nix (npm `next` channel,
        # platform-specific Bun executables).
        package = inputs'.llm-agents.packages.opencode2;

        # `settings` is intentionally empty: OpenCode 1 and 2 share
        # `$XDG_CONFIG_HOME/opencode/opencode.json`, and OpenCode 2
        # normalizes supported V1 fields in memory. When
        # `programs.opencode` (V1) is enabled — as it is here — that module
        # owns the shared file, so shared settings (model, autoupdate) are
        # declared there in the V1 shape.
      };

      persist.directories = [
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
      ];
    };
}
