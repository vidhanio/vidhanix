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
    programs.vscode = {
      package = pkgs.vscode-insiders;
    };

  }
  (lib.mkIf cfg.enable {
    persist.directories = [
      ".config/Code - Insiders/User/globalStorage"
    ];
  })
]
