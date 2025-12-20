{ lib, pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    mutableExtensionsDir = false;

    profiles.default = {
      userSettings = lib.importJSON ./settings.json;

      extensions =
        with pkgs.vscode-marketplace;
        [
          bmalehorn.vscode-fish
          bradlc.vscode-tailwindcss
          charliermarsh.ruff
          codezombiech.gitignore
          github.copilot
          github.copilot-chat
          jnoortheen.nix-ide
          mkhl.direnv
          mkhl.shfmt
          ms-python.python
          ms-python.vscode-pylance
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
          ibecker.treefmt-vscode
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          # https://github.com/redhat-developer/vscode-xml/pull/1112
          redhat.vscode-xml
        ];
    };
  };
}
