{
  flake.modules.homeManager.default =
    { inputs', pkgs, ... }:
    let
      version = "unstable-2026-08-04";
    in
    {
      programs.crush = {
        enable = true;

        # Add the theme-switching support from crush#2731, rebased onto the
        # commit it was opened against, since it does not apply cleanly onto
        # the v0.88.0 release.
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
