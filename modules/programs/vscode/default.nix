{ withSystem, inputs, ... }:
{
  flake-file.inputs.vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

  flake.modules.homeManager.default =
    { pkgs, lib, ... }:
    {
      home.shellAliases.code = "code-insiders";

      programs.vscode = {
        enable = true;
        package = withSystem pkgs.stdenv.hostPlatform.system (
          { self', ... }:
          self'.packages.vscode-insiders.override {
            commandLineArgs = "--password-store=basic";
          }
        );

        mutableExtensionsDir = false;

        profiles.default = {
          userSettings = lib.importJSON ./settings.json;

          extensions =
            with (pkgs.extend inputs.vscode-extensions.overlays.default).vscode-marketplace;
            [
              # keep-sorted start
              anthropic.claude-code
              astral-sh.ty
              bmalehorn.vscode-fish
              bradlc.vscode-tailwindcss
              charliermarsh.ruff
              codezombiech.gitignore
              github.copilot
              github.copilot-chat
              ibecker.treefmt-vscode
              jnoortheen.nix-ide
              mkhl.direnv
              mkhl.shfmt
              ms-python.python
              ms-toolsai.jupyter
              myriad-dreamin.tinymist
              pkief.material-icon-theme
              pkief.material-product-icons
              redhat.vscode-yaml
              rust-lang.rust-analyzer
              timonwong.shellcheck
              tombi-toml.tombi
              tomoki1207.pdf
              ultram4rine.vscode-choosealicense
              vscodevim.vim
              wakatime.vscode-wakatime
              # keep-sorted end
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
              # https://github.com/redhat-developer/vscode-xml/pull/1112
              redhat.vscode-xml
            ];
        };
      };

      persist.directories = [
        ".config/Code - Insiders/User/globalStorage"
      ];
    };
}
