{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.opencode = {
        enable = true;
        package = inputs'.llm-agents.packages.opencode;

        settings = {
          model = "opencode-go/deepseek-v4-flash";
          autoupdate = false;
        };
      };

      home.sessionVariables.OPENCODE_WEBSEARCH_PROVIDER = "exa";

      # No persist: shares XDG dirs already persisted by opencode2.
    };
}
