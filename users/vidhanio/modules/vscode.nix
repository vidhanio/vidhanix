{ pkgs, ... }:
{
  programs.vscode = {
    package = (pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: {
      version = "latest";

      src = builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        sha256 = "sha256:08xqfh48pbm7k23laisacyxkpzjjxf8mwmbv2jfnh8m5klh3hxpz";
      };
    });
  };
}
