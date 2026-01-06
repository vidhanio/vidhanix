{ lib, inputs, ... }:
{
  flake-file.inputs.nixcord.url = "github:FlameFlag/nixcord";

  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      imports = [ inputs.nixcord.homeModules.default ];

      programs.nixcord = {
        enable = true;
        discord.enable = lib.mkDefault false;
        vesktop = {
          enable = true;
          # https://github.com/NixOS/nixpkgs/pull/476514
          package = pkgs.vesktop.overrideAttrs {
            preBuild = lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              cp -r ${pkgs.electron}/libexec/electron electron-dist
              chmod -R u+w electron-dist
            '';

            buildPhase = ''
              runHook preBuild

              pnpm build --standalone
              pnpm exec electron-builder \
                --dir \
                -c.asarUnpack="**/*.node" \
                -c.electronDist=electron-dist \
                -c.electronVersion=${pkgs.electron.version}

              runHook postBuild
            '';
          };
          settings = {
            discordBranch = "canary";
            minimizeToTray = true;
            arRPC = true;
            hardwareAcceleration = true;
            hardwareVideoAcceleration = true;
            customTitleBar = false;
            disableMinSize = true;
          };
          state = {
            firstLaunch = false;
            maximized = true;
          };
        };
        quickCss = ''
          @import url(https://codeberg.org/ridge/Discord-Adblock/raw/branch/main/discord-adblock.css);
        '';
        config = {
          useQuickCss = true;
          plugins = {
            spotifyCrack.enable = true;
            fakeNitro.enable = true;
            youtubeAdblock.enable = true;
            ClearURLs.enable = true;
          };
        };
      };

      persist.directories = [ ".config/vesktop/sessionData/Local Storage" ];
    };
}
