{ lib, config, ... }:
let
  cfg = config.programs.bat;
in
lib.mkIf cfg.enable {
  home.shellAliases.cat = "bat";
}
