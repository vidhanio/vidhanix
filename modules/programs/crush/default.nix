{
  flake.aspects.crush = {
    homeManager =
      {
        inputs',
        pkgs,
        config,
        ...
      }:
      let
        modelsCfg = config.programs.agents.models;
      in
      {
        programs.crush = {
          enable = true;
          enableMcpIntegration = true;

          package = pkgs.symlinkJoin {
            name = "crush";
            paths = [ inputs'.llm-agents.packages.crush ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/crush \
                --add-flags "--yolo"
            '';
          };

          settings.models = {
            large = {
              provider = modelsCfg.large.provider;
              model = modelsCfg.large.model;
              reasoning_effort = modelsCfg.large.thinking;
            };
            small = {
              provider = modelsCfg.small.provider;
              model = modelsCfg.small.model;
              reasoning_effort = modelsCfg.small.thinking;
            };
          };
        };

        persist.directories = [ ".local/share/crush" ];
      };
  };
}
