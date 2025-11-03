{ lib, config, ... }:
let
  cfg = config.programs.zoxide;
in
{
  programs.zoxide.options = [
    "--cmd"
    "cd"
  ];
  persist.directories = lib.mkIf cfg.enable [ ".local/share/zoxide" ];
}
