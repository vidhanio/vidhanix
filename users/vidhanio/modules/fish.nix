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
      ls = "eza --color=auto --group-directories-first";
      ll = "ls -l";
      vi = "nvim";
      code = "code-insiders";
    };
    functions = {
      fish_greeting = "pfetch";
      fish_prompt = "printf '%s%s%s > ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)";
    };
  };
}
