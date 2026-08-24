{
  flake.aspects.agent-browser = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.agent-browser;
        json = pkgs.formats.json { };
      in
      {
        options.programs.agent-browser = {
          enable = lib.mkEnableOption "agent-browser";

          package = lib.mkPackageOption pkgs "agent-browser" { nullable = true; };

          settings = lib.mkOption {
            inherit (json) type;
            default = { };
            example = {
              headed = true;
              hideScrollbars = false;
              contentBoundaries = true;
              maxOutput = 50000;
            };
            description = ''
              Persistent defaults written to {file}`~/.agent-browser/config.json`,
              the user-level configuration agent-browser merges into every
              invocation.

              Keys are the camelCase global launch, output, provider, and chat
              flags documented at <https://agent-browser.dev/configuration>;
              unknown keys are silently ignored, so stick to the documented
              set. A `$schema` key is injected automatically and overridden by
              an explicit one.

              Project-level {file}`agent-browser.json`, `AGENT_BROWSER_*` env
              variables, and CLI flags override these values in that order.
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

          home.file.".agent-browser/config.json" = lib.mkIf (cfg.settings != { }) {
            source = json.generate "agent-browser-config.json" (
              { "$schema" = "https://agent-browser.dev/schema.json"; } // cfg.settings
            );
          };

          programs.agents.skills.skills.agent-browser = lib.mkIf (
            cfg.package != null
          ) "${cfg.package.src}/skills/agent-browser";
        };
      };
  };
}
