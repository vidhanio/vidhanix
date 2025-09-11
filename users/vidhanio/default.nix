{
  lib,
  osConfig,
  inputs,
  pkgs,
  ...
}:
{
  imports =
    (lib.readDirToList ./modules)
    ++ [ ../modules/impermanence.nix ]
    ++ (with inputs; [
      agenix.homeManagerModules.default
    ]);

  home = {
    shell.enableFishIntegration = true;
    packages = with pkgs; ([
      agenix
      bat
      eza
      nil
      nixfmt
      moonlight-qt
      pfetch
      ripgrep
      spotify
      rust-bin.stable.latest.default
    ] ++ lib.optionals (osConfig.networking.hostName == "vidhan-pc") [deskflow vacuumtube wl-clipboard]);

    file = {
      ".hushlogin".text = "";
    };

  };

  impermanence = {
    directories = [
      "Documents"
      "Downloads"
      "Projects"

      ".ssh"
      ".mozilla"
      ".vscode-insiders"

      ".config/1Password"
      ".config/Code - Insiders"
      ".config/vesktop"
    ];
  };

  age.secrets = {
    wakatime = {
      file = ../../secrets/wakatime.age;
      path = ".wakatime.cfg";
    };
  };

  xdg.autostart = {
    enable = true;
    entries = with pkgs; [
      "${vesktop}/share/applications/vesktop.desktop"
      "${firefox-devedition}/share/applications/firefox-devedition.desktop"
      "${_1password-gui}/share/applications/1password.desktop"
      "${spotify}/share/applications/spotify.desktop"
    ] ++ lib.optional (osConfig.networking.hostName == "vidhan-pc") "${solaar}/share/applications/solaar.desktop";
  };
  
  home.stateVersion = "25.05";
}
