{ lib, ... }:
{
  flake.aspects.delta-db = {
    homeManager =
      {
        config,
        pkgs,
        self',
        ...
      }:
      let
        cfg = config.programs.delta-db;
        json = pkgs.formats.json { };
        environment = lib.generators.toKeyValue {
          mkKeyValue = name: value: "${name}=${lib.escapeShellArg value}";
        } cfg.environment;
      in
      {
        options.programs.delta-db = {
          enable = lib.mkEnableOption "Delta";

          package = lib.mkOption {
            type = lib.types.package;
            default = self'.packages.delta-db;
            defaultText = lib.literalExpression "self'.packages.delta-db";
            description = "The Delta package to use.";
          };

          settings = lib.mkOption {
            inherit (json) type;
            default = { };
            example = {
              send_message_with_modifier = false;
              cursor_after_send = "next_user_message";
              diff_color_scheme = "blue_orange";
              diff_signs = true;
              default_diff_base = "last_turn";
              os_notifications = true;
              prevent_system_sleep = true;
            };
            description = "Configuration written to {file}`~/.config/delta/settings.json`.";
          };

          rules = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
            description = "Personal agent rules written to {file}`~/.config/delta/AGENTS.md`.";
          };

          environment = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            example = {
              ANTHROPIC_API_KEY = "example";
              OPENAI_API_KEY = "example";
            };
            description = ''
              Environment variables written to {file}`~/.config/delta/.env`.
              Values are stored in the Nix store; use `environmentFile` for secrets.
            '';
          };

          environmentFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "/run/secrets/delta-env";
            description = ''
              Absolute path to an environment file linked to
              {file}`~/.config/delta/.env`. This keeps secrets out of the Nix store.
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = cfg.environment == { } || cfg.environmentFile == null;
              message = "programs.delta-db.environment and programs.delta-db.environmentFile are mutually exclusive";
            }
            {
              assertion = cfg.environmentFile == null || lib.hasPrefix "/" cfg.environmentFile;
              message = "programs.delta-db.environmentFile must be an absolute path";
            }
          ];

          home.packages = [ cfg.package ];

          xdg.configFile."delta/settings.json" = lib.mkIf (cfg.settings != { }) {
            source = json.generate "delta-settings.json" cfg.settings;
          };

          xdg.configFile."delta/AGENTS.md" = lib.mkIf (cfg.rules != null) {
            text = cfg.rules;
          };

          xdg.configFile."delta/.env" = lib.mkIf (cfg.environment != { } || cfg.environmentFile != null) (
            if cfg.environmentFile != null then
              {
                source = config.lib.file.mkOutOfStoreSymlink cfg.environmentFile;
              }
            else
              {
                text = environment;
              }
          );
        };
      };
  };
}
