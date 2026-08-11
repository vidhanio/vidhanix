_: {
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.pi-coding-agent = {
        enable = true;

        package = pkgs.pi-coding-agent;

        settings = {
          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4-flash";
          defaultThinkingLevel = "max";
        };
      };

      persist.directories = [ ".pi/agent" ];
    };
}
