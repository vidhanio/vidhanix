{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      home.file.".omp/agent/extensions/herdr-omp-agent-state.ts".source =
        "${config.programs.herdr.package.src}/src/integration/assets/omp/herdr-agent-state.ts";
    };
}
