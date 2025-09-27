{ lib, config, ... }:
let
  cfg = config.programs.eza;
in
{
  programs.eza = {
    git = true;
    extraOptions = [
      "--all"
      "--group-directories-first"
    ];
  };

  home.shellAliases = lib.mkIf cfg.enable {
    ls = "eza";
    tree = "eza --tree";
  };
}
