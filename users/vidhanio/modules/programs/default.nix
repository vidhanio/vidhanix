{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  imports = lib.importSubmodules ./.;

  home.packages =
    with pkgs;
    (
      [
        bat
        eza
        moonlight-qt
        pfetch
        ripgrep
      ]
      ++ lib.optionals (osConfig.nixpkgs.hostPlatform.isLinux) [
        deskflow
        vacuumtube
        wl-clipboard
      ]
    );

  programs = {
    home-manager.enable = true;

    neovim.enable = true;
    uv.enable = true;
    zoxide.enable = true;
  };

  xdg.autostart.enable = osConfig.nixpkgs.hostPlatform.isLinux;
}
