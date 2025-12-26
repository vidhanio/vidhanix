{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.vscode;
in
lib.mkMerge [
  {

  }

  (lib.mkIf cfg.enable {
  })
]
