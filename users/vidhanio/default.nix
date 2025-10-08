{
  pkgs,
  osConfig,
  lib,
  ...
}:
{
  imports = lib.readSubmodules ./.;

  home = {
    file = {
      ".hushlogin".text = "";
      ".face".source = pkgs.fetchurl {
        url = "https://github.com/vidhanio.png";
        sha256 = "sha256-ihQAIrfg5L1k1AUWo6Ga7ZuGI00Rha4KaTOowUeCp/E=";
      };
    };
  };

  impermanence = {
    directories = [
      "Downloads"
      "Projects"

      ".cache/nix"
    ];
  };

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
    nixcord = {
      enable = true;
      vesktop.enable = true;
    };
    ripgrep.enable = true;
    vacuum-tube.enable = true;
    vscode.enable = true;
    zoxide.enable = true;
  };

  services = {
    wakatime.enable = true;
  };

  home.packages = with pkgs; [
    nixfmt-rfc-style
    nil

    # fonts
    berkeley-mono-variable
    pragmata-pro-variable
  ];

  fonts.fontconfig.enable = true;

  xdg.autostart.enable = lib.mkIf osConfig.nixpkgs.hostPlatform.isLinux true;

  home.stateVersion = "25.11";
}
