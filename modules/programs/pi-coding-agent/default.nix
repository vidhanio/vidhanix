{
  flake.aspects.pi-coding-agent = {
    homeManager =
      {
        inputs',
        self',
        config,
        ...
      }:
      let
        cfg = config.programs.pi-coding-agent;
        model = config.programs.agents.models.large;

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

          package = inputs'.llm-agents.packages.pi;

          settings = {
            defaultProvider = model.provider;
            defaultModel = model.model;
            defaultThinkingLevel = model.thinking;
            # load package manifests directly from the Nix store.
            packages = [
              "${self'.packages.pi-subagents}/lib/node_modules/pi-subagents"
              "${self'.packages.pi-web-access}/lib/node_modules/pi-web-access"
            ];
          };
        };

        home.file =
          builtins.listToAttrs (
            map (ext: {
              name = "${cfg.configDir}/extensions/${ext}";
              value.source = "${cfg.package.src}/examples/extensions/${ext}";
            }) exampleExtensions
          )
          // {
            "${cfg.configDir}/extensions/todo.ts".source = ./todo.ts;
          };

        xdg.configFile."pi/web-search.json".text = builtins.toJSON {
          workflow = "none";
          searxngBaseUrl = "http://vortex:8888";
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
