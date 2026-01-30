{
  flake.modules.nixos.default = {
    programs.fish.shellInit = ''
      if [ "$TERM_PROGRAM" = "vscode" ]
          set -x VISUAL "code-insiders --wait"
          set -x EDITOR "code-insiders --wait"
      else
          set -x VISUAL nvim
          set -x EDITOR nvim
      end
    '';
  };
}
