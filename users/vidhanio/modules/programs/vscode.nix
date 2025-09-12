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
            sha256 = "sha256:0bcwlmmgldlbxf3hfzyh2xv07q420z0khacdykzck3qr2b46g5q8";
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
