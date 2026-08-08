{
  flake.modules.homeManager.default =
    { inputs', pkgs, ... }:
    let
      version = "unstable-2026-08-04";
    in
    {
      programs.crush = {
        enable = true;

        # Overrides catwalk's reasoning_levels for deepseek-v4 (xhigh maps to
        # high; max is the real max, per DeepSeek's thinking-mode docs).
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

        # Rebases crush#2731 theme-switching onto the pinned rev.
        package = inputs'.llm-agents.packages.crush.overrideAttrs (old: {
          inherit version;

          src = pkgs.fetchFromGitHub {
            owner = "charmbracelet";
            repo = "crush";
            rev = "659ea90fd5035adf67bfb3e4dd8a4f8ee110d9f4";
            hash = "sha256-v3pCmtqZNSF1f3JmKTtYL7KYiRq5oFSl5TwjEH8K7+M=";
          };

          patches = (old.patches or [ ]) ++ [
            (pkgs.fetchpatch {
              url = "https://github.com/charmbracelet/crush/pull/2731.diff";
              hash = "sha256-JN8WLulxKcYKAyKVHABZruuQNwOxyzeKiKui07NEisw=";
            })
            (pkgs.fetchpatch {
              url = "https://github.com/charmbracelet/crush/compare/main...vidhanio:crush:feat/openai-subscription-auth.patch";
              hash = "sha256-VOxW6A7BDdoadWb6E1/KbIqmX8VnJCzmeEVOr4mqaTE=";
            })
          ];

          ldflags = map (pkgs.lib.replaceStrings [ old.version ] [ version ]) old.ldflags;

          vendorHash = "sha256-eZinUIq+silN5RcCZzbxQ9rI0t+GY2ehwsmYVsCnx3k=";
        });
      };
    };
}
