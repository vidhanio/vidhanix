{ lib, config, ... }:
let
  cfg = config.programs.ripgrep;
in
{
  programs.ripgrep.arguments = [ "--hidden" ];
  home.shellAliases.grep = lib.mkIf cfg.enable "rg";
}
