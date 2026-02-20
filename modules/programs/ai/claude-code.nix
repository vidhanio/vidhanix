{ withSystem, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.claude-code = {
        enable = true;
        package = withSystem pkgs.stdenv.hostPlatform.system (
          { inputs', ... }: inputs'.llm-agents.packages.claude-code
        );
      };

      persist.files = [ ".claude/.credentials.json" ];
    };
}
