{ lib, pkgs, ... }:
let
  package = pkgs.firefox-devedition;
in
{
  programs.firefox = {
    enable = true;
    inherit package;
    policies = {
      SearchEngines = {
        Add = [
          {
            Name = "MyNixOS";
            Alias = "@nix";
            URLTemplate = "https://mynixos.com/search?q={searchTerms}";
            Description = "Build and share reproducible software environments with Nix and NixOS";
            IconURL = "https://mynixos.com/favicon-64x64.png";
          }
        ];
      };
    };
  };

  xdg.autostart.entries = map lib.getDesktop [ package ];

  impermanence.directories = [ ".mozilla" ];
}
