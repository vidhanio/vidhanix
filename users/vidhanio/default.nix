{
  osConfig,
  pkgs,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  imports = map (name: ./modules/${name}) (builtins.attrNames (builtins.readDir ./modules));

  home = {
    username = osConfig.me.username;
    homeDirectory =
      let
        parent = if stdenv.isDarwin then "Users" else "home";
      in
      "/${parent}/${osConfig.me.username}";
    shell.enableFishIntegration = true;
    packages = with pkgs; [
      bat
      deskflow
      eza
      nil
      nixfmt
      moonlight-qt
      pfetch
      ripgrep
      spotify
      vacuumtube
      wl-clipboard
      rust-bin.stable.latest.default
    ];
    file.".hushlogin".text = "";
    stateVersion = "25.05";
  };

  xdg.autostart = {
    enable = true;
    entries = with pkgs; [
      "${vesktop}/share/applications/vesktop.desktop"
      "${firefox-devedition}/share/applications/firefox-devedition.desktop"
      "${solaar}/share/applications/solaar.desktop"
      "${_1password-gui}/share/applications/1password.desktop"
      "${spotify}/share/applications/spotify.desktop"
    ];
  };

  programs = {
    home-manager.enable = true;

    neovim.enable = true;
    uv.enable = true;
  };
}
