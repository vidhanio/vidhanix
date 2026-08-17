{
  flake.modules.homeManager.default =
    {
      pkgs,
      self',
      config,
      ...
    }:
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

        settings = {
          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4-flash";
          defaultThinkingLevel = "max";
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

          # Third-party extensions, packaged in extensions/ so the node
          # modules they import resolve; entry points come from each repo's
          # package.json "pi.extensions" manifest.
          "${cfg.configDir}/extensions/subagent".source =
            "${self'.packages.pi-subagents}/lib/node_modules/pi-subagents";
          "${cfg.configDir}/extensions/web-access".source =
            "${self'.packages.pi-web-access}/lib/node_modules/pi-web-access";
          "${cfg.configDir}/extensions/pi-context-view".source = self'.packages.pi-context-view;

          # pi-web-access reads its config (searxng endpoint, SSRF ranges)
          # from ~/.pi/web-search.json, next to the agent dir.
          ".pi/web-search.json".text = builtins.toJSON {
            searxngBaseUrl = "http://vidhan-pc:8080";
            ssrf.allowRanges = [ "100.64.0.0/10" ];
          };
        };

      persist.directories = [ ".pi/agent" ];
    };
}
