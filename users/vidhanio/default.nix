{
  lib,
  osConfig,
  config,
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

    file = {
      ".hushlogin".text = "";
    };

    activation.linkApps = lib.optionalAttrs pkgs.stdenv.isDarwin (
      lib.hm.dag.entryAfter [ "installPackages" ] (
        let
          applications = pkgs.buildEnv {
            name = "user-applications";
            paths = config.home.packages;
            pathsToLink = "/Applications";
          };
        in
        ''
          echo "setting up ~/Applications/Home Manager Apps..." >&2

          ourLink () {
            local link
            link=$(readlink "$1")
            [ -L "$1" ] && [ "''${link#*-}" = 'user-applications/Applications' ]
          }

          targetFolder='Applications/Home Manager Apps'

          if [ -e "$targetFolder" ] && ourLink "$targetFolder"; then
            rm "$targetFolder"
          fi

          mkdir -p "$targetFolder"

          rsyncFlags=(
            --archive
            --checksum
            --chmod=-w
            --chown=$USER:staff
            --copy-unsafe-links
            --delete
            --exclude=$'Icon\r'
            --no-group
            --no-owner
          )

          ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" ${applications}/Applications/ "$targetFolder"
        ''
      )
    );
  };

  targets.darwin.linkApps.enable = false;

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
    enable = pkgs.stdenv.isLinux;
    entries =
      with pkgs;
      [
        "${vesktop}/share/applications/vesktop.desktop"
        "${firefox-devedition}/share/applications/firefox-devedition.desktop"
        "${_1password-gui}/share/applications/1password.desktop"
        "${spotify}/share/applications/spotify.desktop"
      ]
      ++ lib.optional (
        osConfig.networking.hostName == "vidhan-pc"
      ) "${solaar}/share/applications/solaar.desktop";
  };

  home.stateVersion = "25.05";
}
