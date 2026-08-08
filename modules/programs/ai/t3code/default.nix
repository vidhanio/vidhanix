{
  flake.modules.homeManager.default =
    {
      inputs',
      pkgs,
      ...
    }:
    let
      t3code = inputs'.llm-agents.packages.t3code;
      t3code-desktop = inputs'.llm-agents.packages.t3code-desktop;

      t3code-full = pkgs.symlinkJoin {
        pname = "t3code";
        inherit (t3code) version;
        paths = [
          t3code
          t3code-desktop
        ];

        inherit (t3code) meta;
        inherit (t3code) passthru;
      };
    in
    {
      programs.t3code = {
        enable = true;
        package = t3code-full;

        userSettings = {
          enableProviderUpdateChecks = false;

          textGenerationModelSelection = {
            instanceId = "opencode";
            model = "opencode-go/deepseek-v4-flash";
            options = [
              {
                id = "variant";
                value = "max";
              }
            ];
          };

          providerInstances = {
            claudeAgent = {
              driver = "claudeAgent";
              enabled = false;
            };
            codex = {
              driver = "codex";
              enabled = false;
            };
            grok = {
              driver = "grok";
              enabled = false;
            };
          };
        };

        keybindings = [ ];

        clientSettings = {
          favorites = [
            {
              provider = "opencode";
              model = "opencode-go/deepseek-v4-flash";
            }
          ];
        };

        mutableUserSettings = false;
        mutableKeybindings = false;
        mutableClientSettings = false;
      };

      persist.directories = [ ".t3" ];
    };
}
