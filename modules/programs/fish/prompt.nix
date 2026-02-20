{ lib, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.fish.functions = {
        fish_greeting = lib.getExe pkgs.pfetch;
        fish_prompt = "printf '%s%s%s > ' (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)";
      };
    };
}
