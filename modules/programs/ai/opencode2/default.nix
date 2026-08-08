_: {
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.opencode2 = {
        enable = true;
        package = inputs'.llm-agents.packages.opencode2;

        # Shared with OpenCode 1 (programs.opencode); it owns opencode.json.
      };

      persist.directories = [
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
      ];
    };
}
