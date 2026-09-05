{
  flake-file.inputs.helium.url = "github:schembriaiden/helium-browser-nix-flake";

  flake.aspects.helium.homeManager =
    {
      config,
      inputs',
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.helium;
      chromeWebStoreUpdateUrl = "https://clients2.google.com/service/update2/crx";

      configDir =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "Library/Application Support/net.imput.helium"
        else
          "${config.xdg.configHome}/net.imput.helium";

      extensionType = lib.types.submodule {
        options = {
          id = lib.mkOption {
            type = lib.types.strMatching "[a-zA-Z]{32}";
            description = ''
              The extension's ID from the Chrome Web Store url or the unpacked crx.
            '';
            default = "";
          };

          updateUrl = lib.mkOption {
            type = lib.types.str;
            default = chromeWebStoreUpdateUrl;
            description = ''
              URL of the extension's update manifest XML file.
            '';
          };

          crxPath = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path to the extension's crx file.
            '';
          };

          version = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              The extension's version, required for local installation.
            '';
          };
        };
      };

      extensionJson =
        ext:
        assert ext.crxPath != null -> ext.version != null;
        {
          name = "${configDir}/External Extensions/${ext.id}.json";
          value.text = builtins.toJSON (
            if ext.crxPath != null then
              {
                external_crx = ext.crxPath;
                external_version = ext.version;
              }
            else
              {
                external_update_url = ext.updateUrl;
              }
          );
        };

      dictionary = pkg: {
        name = "${configDir}/Dictionaries/${pkg.passthru.dictFileName}";
        value.source = pkg;
      };

      nativeMessagingHostsJoined = pkgs.symlinkJoin {
        name = "helium-native-messaging-hosts";
        paths = lib.unique cfg.nativeMessagingHosts;
      };
    in
    {
      options.programs.helium = {
        enable = lib.mkEnableOption "Helium";

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = inputs'.helium.packages.default;
          defaultText = lib.literalExpression "inputs'.helium.packages.default";
          description = "The Helium package to use.";
        };

        finalPackage = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          readOnly = true;
          description = ''
            Resulting customized Helium package.

            This includes any Home Manager customizations such as
            `commandLineArgs`, and can be referenced from other Home Manager
            options through `config.programs.helium.finalPackage`.
          '';
        };

        commandLineArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [
            "--enable-logging=stderr"
            "--ignore-gpu-blocklist"
          ];
          description = ''
            List of command-line arguments to be passed to Helium.

            For a list of common switches, see
            [Chrome switches](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/chrome/common/chrome_switches.cc).

            To search switches for other components, see
            [Chromium codesearch](https://source.chromium.org/search?q=file:switches.cc&ss=chromium%2Fchromium%2Fsrc).
          '';
        };

        dictionaries = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          example = lib.literalExpression ''
            [
              pkgs.hunspellDictsChromium.en_US
            ]
          '';
          description = "List of Helium dictionaries to install.";
        };

        nativeMessagingHosts = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          example = lib.literalExpression ''
            [
              pkgs.keepassxc
            ]
          '';
          description = "List of Helium native messaging hosts to install.";
        };

        extensions = lib.mkOption {
          type = lib.types.listOf (lib.types.coercedTo lib.types.str (v: { id = v; }) extensionType);
          default = [ ];
          example = lib.literalExpression ''
            [
              { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
              {
                id = "dcpihecpambacapedldabdbpakmachpb";
                updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
              }
              {
                id = "aaaaaaaaaabbbbbbbbbbcccccccccc";
                crxPath = "/home/share/extension.crx";
                version = "1.0";
              }
            ]
          '';
          description = ''
            List of Helium extensions to install.
            To find the extension ID, check its URL on the
            [Chrome Web Store](https://chrome.google.com/webstore/category/extensions).

            To install extensions outside of the Chrome Web Store set
            `updateUrl` or `crxPath` and `version` as explained in the
            [Chrome
            documentation](https://developer.chrome.com/docs/extensions/mv2/external_extensions).

            When using Helium on Linux, prefer `crxPath` and `version`. The
            default Chrome Web Store update URL is generally not sufficient
            there.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = !(cfg.package == null && cfg.commandLineArgs != [ ]);
            message = "Cannot set `commandLineArgs` when `package` is null for Helium.";
          }
        ];

        programs.helium.finalPackage =
          if cfg.package == null then
            null
          else if cfg.commandLineArgs != [ ] then
            pkgs.symlinkJoin {
              inherit (cfg.package) pname version meta;
              paths = [ cfg.package ];
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/helium \
                  ${lib.concatMapStringsSep " " (arg: "--add-flags ${lib.escapeShellArg arg}") cfg.commandLineArgs}
              '';
            }
          else
            cfg.package;

        home.packages = lib.mkIf (cfg.finalPackage != null) [ cfg.finalPackage ];

        home.file =
          lib.listToAttrs (map extensionJson cfg.extensions)
          // lib.listToAttrs (map dictionary cfg.dictionaries)
          // {
            "${configDir}/NativeMessagingHosts" = lib.mkIf (cfg.nativeMessagingHosts != [ ]) {
              source = "${nativeMessagingHostsJoined}/etc/chromium/native-messaging-hosts";
              recursive = true;
            };
          };
      };
    };
}
