{
  osConfig,
  lib,
  pkgs,
  ...
}:
{
  imports = lib.readCurrentDir ./.;

  home.packages =
    with pkgs;
    (
      [
        agenix
        bat
        eza
        moonlight-qt
        pfetch
        ripgrep
        spotify
      ]
      ++ lib.optionals (osConfig.networking.hostName == "vidhan-pc") [
        deskflow
        vacuumtube
        wl-clipboard
      ]
    );

  programs = {
    home-manager.enable = true;

    neovim.enable = true;
    uv.enable = true;
    vesktop.enable = true;
  };
}
