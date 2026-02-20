{ withSystem, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        package = withSystem pkgs.stdenv.hostPlatform.system (
          { inputs', ... }: inputs'.llm-agents.packages.opencode
        );
      };
    };
}
