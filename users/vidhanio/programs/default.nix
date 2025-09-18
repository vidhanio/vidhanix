{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  home.packages =
    with pkgs;
    (
      [
        bat
        eza
        moonlight-qt
        pfetch
        ripgrep
        sunshine
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
  };

  xdg.autostart.enable = osConfig.nixpkgs.hostPlatform.isLinux;
}
