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
      if (osConfig.nixpkgs.hostPlatform.system == "x86_64-linux") then
        (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: {
          version = "latest";

          src = builtins.fetchTarball {
            url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
            sha256 = "sha256:14qpn3cng18lkzrrqmibxmxlw39xhxrq7driq8v9spcghsn4j89g";
          };
        })
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
