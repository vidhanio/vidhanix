{
  flake.aspects.pi-coding-agent = {
    homeManager =
      { pkgs, config, ... }:
      let
        cfg = config.programs.pi-coding-agent;

        exampleExtensions = [
          # keep-sorted start
          "confirm-destructive.ts"
          "dirty-repo-guard.ts"
          "git-checkpoint.ts"
          "handoff.ts"
          "protected-paths.ts"
          "question.ts"
          "questionnaire.ts"
          "session-name.ts"
          # keep-sorted end
        ];
      in
      {
        programs.pi-coding-agent = {
          enable = true;

          package = pkgs.pi-coding-agent;
          extraPackages = [ pkgs.nodejs ];

          settings = {
            defaultProvider = "opencode-go";
            defaultModel = "deepseek-v4-flash";
            defaultThinkingLevel = "max";
            packages = [
              "npm:pi-context-view"
              "npm:pi-subagents"
              "npm:pi-web-access"
            ];
          };
        };

        # Extensions load from the auto-discovered extensions dir, so symlink
        # them there instead of listing them in settings.extensions.
        home.file =
          builtins.listToAttrs (
            map (ext: {
              name = "${cfg.configDir}/extensions/${ext}";
              value.source = "${cfg.package.src}/packages/coding-agent/examples/extensions/${ext}";
            }) exampleExtensions
          )
          // {
            # Patched copy: upstream todo.ts renderResult returns undefined for
            # validation-failed results (`details: {}`), crashing the TUI.
            "${cfg.configDir}/extensions/todo.ts".source = ./todo.ts;
          };

        # pi-web-access reads its config from XDG_CONFIG_HOME when set.
        xdg.configFile."pi/web-search.json".text = builtins.toJSON {
          searxngBaseUrl = "http://vortex:8080";
          ssrf.allowRanges = [
            # vortex resolves to this loopback alias locally.
            "127.0.0.2/32"
            # only needed when vortex resolves to a tailnet address.
            "100.64.0.0/10"
          ];
        };

        persist.directories = [ ".pi/agent" ];
      };
  };
}
