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
            sha256 = "sha256:08kc0xmjs5rv6zv3zljy2k5advi7k5g61mwv5jbrqz3cnpx3l3sg";
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
