{
  osConfig,
  ...
}:
{
  programs = {
    _1password.enable = true;
    bat.enable = true;
    cider-2.enable = true;
    direnv.enable = true;
    eza.enable = true;
    firefox.enable = true;
    fish.enable = true;
    gh = {
      enable = true;
      username = "vidhanio";
    };
    ghostty.enable = true;
    git = {
      enable = true;
      userEmail = "me@vidhan.io";
    };
    neovim.enable = true;
    ripgrep.enable = true;
    vesktop.enable = true;
    vscode.enable = true;
    zoxide.enable = true;
  };

  xdg.autostart.enable = osConfig.nixpkgs.hostPlatform.isLinux;
}
