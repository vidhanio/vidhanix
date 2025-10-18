{
  pkgs,
  osConfig,
  config,
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
    direnv.enable = true;
    eza.enable = true;
    firefox.enable = true;
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
    vacuum-tube.enable = true;
    vesktop.enable = true;
    vscode.enable = true;
    zoxide.enable = true;
    nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/Projects/vidhanix";
    };
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

  desktop.dock = with config.programs; [
    {
      package = pkgs.nautilus;
      name = "org.gnome.Nautilus.desktop";
    }
    ghostty.package
    firefox.package
    {
      inherit (vscode) package;
      name = "code-insiders.desktop";
    }
    vesktop.package
  ];

  fonts.fontconfig.enable = true;

  xdg.autostart.enable = true;

  home.stateVersion = "25.11";
}
