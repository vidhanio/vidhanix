{
  flake.aspects.crush = {
    homeManager =
      {
        inputs',
        pkgs,
        ...
      }:
      {
        programs.crush = {
          enable = true;
          enableMcpIntegration = true;

          package = pkgs.symlinkJoin {
            name = "crush";
            paths = [ inputs'.llm-agents.packages.crush ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/crush \
                --add-flags "--yolo"
            '';
          };
        };

        persist.directories = [ ".local/share/crush" ];
      };
  };
}
