{ lib, config, ... }:
let
  cfg = config.programs.zoxide;
in
lib.mkIf cfg.enable {
  impermanence.directories = [ ".local/share/zoxide" ];
}
