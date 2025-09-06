{ pkgs, ... }:
{
  programs.firefox = {
    package = pkgs.firefox-devedition;
    nativeMessagingHosts = with pkgs; [ kdePackages.plasma-browser-integration ];
  };
}
