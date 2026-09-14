{ lib, ... }:
{
  flake-file.inputs.spotifast.url = "github:crmne/spotifast";

  flake.aspects.spotifast = {
    homeManager =
      {
        config,
        inputs',
        pkgs,
        ...
      }:
      let
        cfg = config.programs.spotifast;
        json = pkgs.formats.json { };
      in
      {
        options.programs.spotifast = {
          enable = lib.mkEnableOption "spotifast";

          package = lib.mkOption {
            type = lib.types.package;
            default = inputs'.spotifast.packages.spotifast;
            defaultText = lib.literalExpression "inputs'.spotifast.packages.spotifast";
            description = "The spotifast package to use.";
          };

          settings = lib.mkOption {
            inherit (json) type;
            default = { };
            description = "Configuration written to {file}`~/.config/fastpotify/settings.json`.";
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = [ cfg.package ];

          # upstream keeps the pre-rename config directory.
          xdg.configFile."fastpotify/settings.json" = lib.mkIf (cfg.settings != { }) {
            source = json.generate "fastpotify-settings.json" cfg.settings;
          };
        };
      };
  };
}
