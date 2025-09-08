{ pkgs, ... }:
{
  programs.vscode = {
    package = (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: {
      version = "latest";

      src = builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        sha256 = "sha256:18crg686nn6kl73dglmk1ggwji7pgk0jz6576cnzmcgqzzaw2xg0";
      };
    });
  };
}
