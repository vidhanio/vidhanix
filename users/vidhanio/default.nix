{
  pkgs,
  osConfig,
  config,
  lib,
  ...
}:
{
  imports = lib.readImportsRecursively ./.;

  home = {
    file = {
      ".hushlogin".text = "";
      ".face".source = pkgs.fetchurl {
        url = "https://github.com/vidhanio.png";
        sha256 = "sha256-ihQAIrfg5L1k1AUWo6Ga7ZuGI00Rha4KaTOowUeCp/E=";
      };
    };

    packages = with pkgs; [
      nixfmt-rfc-style
      nil

      helium-bin
    ];
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
    dolphin-emu.enable = true;
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

  services = {
    wakatime.enable = true;
  };

  roms = {
    enable = true;
    systems = lib.mkMerge [
      (lib.mkIf (osConfig.networking.hostName == "vidhan-pc") {
        nes.games = [
          "Super Mario Bros. (World)"
        ];

        n64.games = [
          "Mario Kart 64 (USA)"
          "Paper Mario (USA)"
        ];

        wii.games = [
          {
            name = "New Super Mario Bros. Wii (USA) (En,Fr,Es) (Rev 2)";
            hash = "sha1-4hMjtyrMo9tEi1oKNwQohRuSJBQ=";
          }
          {
            name = "Kirby's Epic Yarn (USA) (En,Fr,Es)";
            hash = "sha1-t1tltpHmtED+djMXtj05W2rVhfI=";
          }
          {
            name = "Mario Kart Wii (USA) (En,Fr,Es)";
            hash = "sha1-mx13tUxzPt2IMe0oRWweEBiwS+k=";
          }
          {
            name = "Marble Saga - Kororinpa (USA) (En,Fr,Es)";
            hash = "sha1-5BLSY/FIjz1ohV7Zs48UHPJgoCI=";
          }
          {
            name = "Disney-Pixar Cars (USA) (En,Es)";
            hash = "sha1-LA2PEsBOdpWgiTbXMRAjIei+zfk=";
          }
          {
            name = "Wii Play (USA) (Rev 1)";
            hash = "sha1-WoPx+LcgYncDyBsj+4uc8tofhcc=";
          }
          {
            name = "Super Smash Bros. Brawl (USA, Canada) (Rev 2)";
            hash = "sha1-a4gfqsmmKoMfTV8ZzpRFUXzKyUI=";
          }
        ];
      })
      (lib.mkIf (osConfig.networking.hostName == "vidhan-macbook") {
        wii.games = [
          {
            name = "Mario Kart Wii (USA) (En,Fr,Es)";
            hash = "sha1-mx13tUxzPt2IMe0oRWweEBiwS+k=";
          }
          {
            name = "Wii Play (USA) (Rev 1)";
            hash = "sha1-WoPx+LcgYncDyBsj+4uc8tofhcc=";
          }
        ];
      })
    ];
  };

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
        pkgs.helium-bin
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

  home.stateVersion = "26.05";
}
