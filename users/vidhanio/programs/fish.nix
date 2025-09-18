{
  programs.fish = {
    enable = true;
    shellInit = ''
      if [ "$TERM_PROGRAM" = "vscode" ]
          set -x EDITOR "code-insiders --wait"
      else
          set -x EDITOR nvim
      end
    '';
    shellAliases = {
      cat = "bat";
      ls = "eza -a --group-directories-first";
      code = "code-insiders";
    };
    functions = {
      fish_greeting = "pfetch";
      fish_prompt = "printf '%s%s%s > ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)";
    };
  };

  impermanence.files = [ ".local/share/fish/fish_history" ];
}
