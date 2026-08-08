{
  flake.modules.homeManager.default =
    { inputs', ... }:
    {
      programs.t3-code = {
        enable = true;
        package = inputs'.llm-agents.packages.t3code;

        desktop = {
          enable = true;
          package = inputs'.llm-agents.packages.t3code-desktop;
        };

        settings = {
          enableProviderUpdateChecks = false;

          textGenerationModelSelection = {
            instanceId = "opencode";
            model = "opencode-go/deepseek-v4-flash";
            # Max effort = the OpenCode `variant` option.
            options = [
              {
                id = "variant";
                value = "max";
              }
            ];
          };

          providers.opencode = {
            enabled = true;
          };
        };
      };

      persist.directories = [ ".t3" ];
    };
}
