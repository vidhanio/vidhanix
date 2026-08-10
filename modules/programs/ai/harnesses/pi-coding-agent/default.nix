_: {
  flake.modules.homeManager.default =
    { pkgs, self', ... }:
    {
      programs.pi-coding-agent = {
        enable = true;

        package = pkgs.pi-coding-agent;

        settings = {
          # @czottmann/pi-automode, loaded straight from the Nix store.
          extensions = [ "${self'.packages.pi-automode}/extensions/auto-mode.ts" ];

          defaultProvider = "opencode-go";
          defaultModel = "deepseek-v4-flash";
          defaultThinkingLevel = "max";
        };
      };

      persist.directories = [ ".pi/agent" ];
    };
}
