{
  flake.aspects.hermes.provides.gateway = {
    homeManager =
      { config, pkgs, ... }:
      let
        plugin = pkgs.symlinkJoin {
          name = "herdr-agent-state";
          paths = [ "${config.programs.herdr.package.src}/src/integration/assets/hermes" ];
        };
      in
      {
        services.hermes-agent = {
          extraPlugins = [ plugin ];
          settings.plugins.enabled = [ "herdr-agent-state" ];
        };
      };
  };
}
