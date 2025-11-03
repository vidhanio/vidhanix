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
      profiles.default.userSettings = {
        "workbench.colorCustomizations" = {
          "[Stylix]" = with config.lib.stylix.colors.withHashtag; {
            "walkthrough.stepTitle.foreground" = base05;
            "terminal.initialHintForeground" = base03;
          };
        };
      };
    };

  }
  (lib.mkIf cfg.enable {
    persist.directories = [
      ".config/Code - Insiders/User/globalStorage"
    ];
  })
]
