{
  flake.modules.homeManager.default =
    { inputs', pkgs, ... }:
    {
      programs.opencode2 = {
        enable = true;
        enableMcpIntegration = true;

        package =
          let
            opencode2 = inputs'.llm-agents.packages.opencode2;
          in
          pkgs.symlinkJoin {
            name = "opencode2";
            paths = [ opencode2 ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/opencode2 \
                --set OPENCODE_WEBSEARCH_PROVIDER exa
            '';
          };

        settings = {
          model = "opencode-go/deepseek-v4-flash";
        };
      };

      persist.directories = [
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
      ];
    };
}
