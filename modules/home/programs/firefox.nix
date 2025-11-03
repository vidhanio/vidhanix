{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.firefox;
  profileName = "dev-edition-default";
in
lib.mkIf cfg.enable {
  programs.firefox = {
    package = pkgs.firefox-devedition;

    profiles.${profileName} = {
      extensions = {
        force = true;
        packages = with pkgs.firefox-addons; [
          onepassword-password-manager
          ublock-origin
          csgofloat
        ];
      };

      settings = {
        "extensions.autoDisableScopes" = 0;
      };

      search = {
        force = true;
        engines = {
          my-nixos = {
            name = "MyNixOS";
            urls = [
              {
                template = "https://mynixos.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://mynixos.com/favicon-64x64.png";
            definedAliases = [ "@nix" ];
          };

          nix-packages = {
            name = "Nix Packages";
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@pkg" ];
          };

          noogle = {
            name = "Noogle";
            urls = [
              {
                template = "https://noogle.dev/q";
                params = [
                  {
                    name = "term";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@noogle" ];
          };

          nixos-wiki = {
            name = "NixOS Wiki";
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nixwiki" ];
          };
        };
      };
    };
  };

  persist.directories = [ ".mozilla/firefox/${profileName}" ];

  stylix.targets.firefox = {
    firefoxGnomeTheme.enable = true;
    profileNames = [ profileName ];
  };
}
