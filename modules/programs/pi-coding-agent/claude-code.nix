{
  profiles.pc.homeModule =
    {
      config,
      inputs',
      self',
      ...
    }:
    {
      programs.claude-code = {
        enable = true;
        package = inputs'.llm-agents.packages.claude-code;
      };

      programs.pi-coding-agent.settings.packages = [
        "${
          self'.packages.pi-claude-code.override {
            claude-code = config.programs.claude-code.package;
          }
        }/lib/node_modules/pi-claude-code"
      ];

      persist.files = [ ".claude/.credentials.json" ];
    };
}
