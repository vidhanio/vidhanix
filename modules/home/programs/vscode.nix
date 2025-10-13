{
  osConfig,
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
    programs.vscode.package =
      if osConfig.nixpkgs.hostPlatform.system == "x86_64-linux" then
        pkgs.vscode-insiders
      else
        pkgs.vscode;
  }
  (lib.mkIf cfg.enable {
    impermanence.directories = [
      ".vscode-insiders"
      ".config/Code - Insiders"
    ];

    stylix.targets.vscode.enable = false;
  })
]
