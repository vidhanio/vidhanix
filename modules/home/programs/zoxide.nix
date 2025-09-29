{ lib, config, ... }:
let
  cfg = config.programs.zoxide;
in
{
  programs.zoxide.options = [
    "--cmd"
    "cd"
  ];
  impermanence.directories = lib.mkIf cfg.enable [ ".local/share/zoxide" ];
}
