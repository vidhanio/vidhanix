{ lib, ... }:
{
  flake.aspects.fastpotify = {
    homeManager =
      {
        config,
        inputs',
        pkgs,
        ...
      }:
      let
        cfg = config.programs.fastpotify;
        json = pkgs.formats.json { };
      in
      {
        options.programs.fastpotify = {
          enable = lib.mkEnableOption "fastpotify";

          package = lib.mkOption {
            type = lib.types.package;
            default = inputs'.fastpotify.packages.fastpotify;
            defaultText = lib.literalExpression "inputs'.fastpotify.packages.fastpotify";
            description = "The fastpotify package to use.";
          };

          settings = lib.mkOption {
            inherit (json) type;
            default = { };
            example = {
              theme = "dark";
            };
            description = "Configuration written to {file}`~/.config/fastpotify/settings.json`.";
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = [ cfg.package ];

          xdg.configFile."fastpotify/settings.json" = lib.mkIf (cfg.settings != { }) {
            source = json.generate "fastpotify-settings.json" cfg.settings;
          };
        };
      };
  };
}
