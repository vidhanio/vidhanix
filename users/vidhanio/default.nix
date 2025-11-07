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

  persist = {
    directories = [
      "Downloads"
      "Projects"

      ".cache/nix"
    ];
  };

  programs = {
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
      settings.user.email = "me@vidhan.io";
    };
    neovim.enable = true;
    prismlauncher.enable = true;
    ripgrep.enable = true;
    spotify-player.enable = true;
    spicetify.enable = pkgs.stdenv.hostPlatform.isx86_64;
    vacuum-tube.enable = true;
    vesktop.enable = true;
    vscode.enable = true;
    zellij.enable = true;
    zoxide.enable = true;
  };

  services = {
    wakatime.enable = true;
  };

  home.packages = with pkgs; [
    nixfmt-rfc-style
    nil
  ];

  apps =
    let
      ifEnabled = lib.concatMap (program: lib.optional program.enable program.package);
      inherit (config) programs;
      osPrograms = osConfig.programs;
      maybeSpicetify = lib.optional programs.spicetify.enable programs.spicetify.spicedSpotify;
    in
    {
      autostart = [
        {
          package = pkgs.solaar;
          name = "solaar-autostart.desktop";
        }
        programs.firefox.finalPackage
        programs.vesktop.package
      ]
      ++ maybeSpicetify
      ++ ifEnabled [
        osPrograms._1password-gui
        osPrograms.steam
      ];

      dock = [
        {
          package = pkgs.nautilus;
          name = "org.gnome.Nautilus.desktop";
        }
        programs.ghostty.package
        programs.firefox.finalPackage
        {
          inherit (programs.vscode) package;
          name = "code-insiders.desktop";
        }
        programs.vesktop.package
      ]
      ++ maybeSpicetify
      ++ ifEnabled [
        osPrograms.steam
      ];
    };

  home.stateVersion = "25.11";
}
