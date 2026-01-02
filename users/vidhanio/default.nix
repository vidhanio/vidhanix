{
  pkgs,
  osConfig,
  config,
  lib,
  ...
}:
{
  imports = lib.readImportsRecursively ./.;

  programs = {
    bat.enable = true;
    direnv.enable = true;
    dolphin-emu.enable = true;
    eza.enable = true;
    helium.enable = true;
    gh = {
      enable = true;
      username = "vidhanio";
    };
    ghostty.enable = true;
    git = {
      enable = true;
      settings.user.email = "me@vidhan.io";
    };
    neovim.enable = true;
    prismlauncher.enable = true;
    retroarch = {
      enable = true;
      settings = {
        menu_swap_ok_cancel_buttons = "true";
        input_player1_joypad_index = "1"; # Controller
      };
    };
    ripgrep.enable = true;
    spotify-player.enable = true;
    spicetify.enable = pkgs.stdenv.hostPlatform.isx86_64;
    vacuum-tube.enable = true;
    vesktop.enable = true;
    vscode.enable = true;
    zellij.enable = true;
    zoxide.enable = true;
  };

  home.stateVersion = "26.05";
}
