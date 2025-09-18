{ config, pkgs, ... }:
{

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    nativeMessagingHosts =
      with pkgs;
      lib.optional (config.programs.plasma.enable) kdePackages.plasma-browser-integration;
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

  xdg.autostart.entries = with pkgs; [
    "${firefox-devedition}/share/applications/firefox-devedition.desktop"
  ];

  impermanence.directories = [ ".mozilla" ];
}
