{ osConfig, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package =
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
  };

  impermanence.directories = [
    ".vscode-insiders"
    ".config/Code - Insiders"
  ];
}
