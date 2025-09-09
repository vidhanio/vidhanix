{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    nativeMessagingHosts = with pkgs; [ kdePackages.plasma-browser-integration ];
  };
}
