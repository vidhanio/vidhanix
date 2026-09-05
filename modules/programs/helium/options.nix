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
      };
    };
}
