{
  flake.aspects.pi-coding-agent = {
    homeManager =
      {
        inputs',
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

          package = inputs'.llm-agents.packages.pi;

          settings = {
            packages = [ "npm:pi-web-access" ];
          };
        };

        home.file =
          builtins.listToAttrs (
            map (ext: {
              name = "${cfg.configDir}/extensions/${ext}";
              value.source = "${cfg.package.src}/packages/coding-agent/examples/extensions/${ext}";
            }) exampleExtensions
          )
          // {
            "${cfg.configDir}/extensions/todo.ts".source = ./todo.ts;
          };

        xdg.configFile."pi/web-search.json".text = builtins.toJSON {
          workflow = "none";
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
