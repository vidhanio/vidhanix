{ lib, pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    mutableExtensionsDir = false;

    profiles.default = {
      userSettings = lib.importJSON ./settings.json;

      extensions = with pkgs.vscode-marketplace; [
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
        redhat.vscode-xml
        redhat.vscode-yaml
        rust-lang.rust-analyzer
        timonwong.shellcheck
        tombi-toml.tombi
        ultram4rine.vscode-choosealicense
        vscodevim.vim
        wakatime.vscode-wakatime
      ];
    };
  };
}
