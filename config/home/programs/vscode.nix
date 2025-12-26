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
<<<<<<< HEAD

=======
    programs.vscode = {
      package = pkgs.vscode-insiders;
    };
>>>>>>> 3554110 (add changes)
  }

  (lib.mkIf cfg.enable {
  })
]
