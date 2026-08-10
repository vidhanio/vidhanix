{ inputs, ... }:
{
  # TODO: https://github.com/charmbracelet/crush/pull/2731
  flake-file.inputs.crush = {
    url = "github:gurnben/crush/feat/theme-support";
    flake = false;
  };

  perSystem.files.gitignore = ".crush";

  flake.modules.homeManager.default =
    {
      inputs',
      pkgs,
      ...
    }:
    let
      pkg = inputs'.llm-agents.packages.crush.overrideAttrs (_old: {
        src = inputs.crush;

        vendorHash = "sha256-eZinUIq+silN5RcCZzbxQ9rI0t+GY2ehwsmYVsCnx3k=";
      });
    in
    {
      programs.crush = {
        enable = true;
        enableMcpIntegration = true;

        package = pkgs.symlinkJoin {
          name = "crush";
          paths = [ pkg ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/crush \
              --add-flags "--yolo"
          '';
        };

        # TODO: https://github.com/charmbracelet/catwalk/pull/501
        settings = {
          providers.opencode-go.models = [
            {
              id = "deepseek-v4-flash";
              name = "DeepSeek V4 Flash (2x usage)";
              cost_per_1m_in = 0.07;
              cost_per_1m_out = 0.14;
              cost_per_1m_in_cached = 0;
              cost_per_1m_out_cached = 0;
              context_window = 1000000;
              default_max_tokens = 384000;
              can_reason = true;
              reasoning_levels = [
                "low"
                "high"
                "max"
              ];
              default_reasoning_effort = "max";
              supports_attachments = false;
            }
          ];

          models.large = {
            model = "deepseek-v4-flash";
            provider = "opencode-go";
            reasoning_effort = "max";
          };
        };
      };

      persist.directories = [ ".local/share/crush" ];
    };
}
