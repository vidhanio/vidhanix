{
  lib,
  osConfig,
  config,
  pkgs,
  ...
}:
let
  osCfg = osConfig.programs.fish;
  cfg = config.programs.fish;
in
{
  programs.fish = {
    enable = osCfg.enable;
    shellInit = ''
      if [ "$TERM_PROGRAM" = "vscode" ]
          set -x EDITOR "code-insiders --wait"
      else
          set -x EDITOR nvim
      end

      fish_vi_key_bindings
    '';
    functions = {
      fish_greeting = "${pkgs.pfetch}";
      fish_prompt = "printf '%s%s%s > ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)";
    };
  };

  impermanence.files = lib.mkIf cfg.enable [ ".local/share/fish/fish_history" ];
}
