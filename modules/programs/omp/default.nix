{ inputs, ... }:
{
  flake-file.inputs.omp.url = "github:can1357/oh-my-pi";
  flake.aspects.omp = {
    homeManager =
      {
        inputs',
        config,
        osConfig,
        ...
      }:
      let
        modelsCfg = config.programs.agents.models;
        searxngCfg = osConfig.services.searx.settings.server;
      in
      {
        imports = [ inputs.omp.homeManagerModules.default ];

        programs.omp = {
          enable = true;
          enableMcpIntegration = true;
          package = inputs'.llm-agents.packages.omp;

          models = {
            providers.opencode-go.modelOverrides."deepseek-v4.1-flash".contextWindow = 200000;
          };

          settings = {
            startup = {
              setupWizard = false;
              checkUpdate = false;
            };

            task.isolation.enabled = true;
            composer.shape = "pi";
            symbolPreset = "nerd";

            completion.notify = "off";
            ask.notify = "off";

            modelRoles = {
              default = "${modelsCfg.default.provider}/${modelsCfg.default.model}:${modelsCfg.default.thinking}";
              smol = "${modelsCfg.small.provider}/${modelsCfg.small.model}:${modelsCfg.small.thinking}";
              slow = "${modelsCfg.large.provider}/${modelsCfg.large.model}:${modelsCfg.large.thinking}";
              web = "web/searxng";
            };

            searxng.endpoint = "http://${searxngCfg.bindAddress}:${toString searxngCfg.port}";
          };
        };

        persist.directories = [ ".omp" ];
      };
  };
}
