_: {
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.opencode2 = {
        enable = true;
        package = inputs'.llm-agents.packages.opencode2;

        settings = {
          model = "opencode-go/deepseek-v4-flash";
          autoupdate = false;
        };
      };

      home.sessionVariables.OPENCODE_WEBSEARCH_PROVIDER = "exa";

      persist.directories = [
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
      ];
    };
}
