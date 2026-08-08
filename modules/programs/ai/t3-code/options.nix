{
  flake.modules.homeManager.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.t3-code;
      jsonFormat = pkgs.formats.json { };
    in
    {
      options.programs.t3-code = {
        enable = lib.mkEnableOption "T3 Code";

        package = lib.mkPackageOption pkgs "t3-code" {
          nullable = true;
          default = null;
        };

        desktop = {
          enable = lib.mkEnableOption "the T3 Code desktop app";

          package = lib.mkPackageOption pkgs "t3-code-desktop" {
            nullable = true;
            default = null;
          };
        };

        settings = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
          example = {
            enableProviderUpdateChecks = false;
            textGenerationModelSelection = {
              instanceId = "opencode";
              model = "opencode-go/deepseek-v4-flash";
            };
            providers.opencode.enabled = true;
          };
          description = ''
            Server settings written to {file}`~/.t3/userdata/settings.json`
            (the state dir is `~/.t3`, overridable with `T3CODE_HOME`).

            The binary and its provider CLIs are Nix-managed, so consider
            `enableProviderUpdateChecks = false`. The default model for new
            threads and for generated text (thread titles, commit messages,
            PR content) is `textGenerationModelSelection`; for the OpenCode
            provider the `model` must use the `provider/model` slug format
            (e.g. `opencode-go/deepseek-v4-flash`).

            See
            <https://github.com/pingdotgg/t3code/blob/main/packages/contracts/src/settings.ts>
            for the schema. Unknown keys are ignored, and settings changed in
            the UI are written back to this file by the server.

            Note: T3 Code has no declarative theme files — custom themes live
            in the client's localStorage only (`t3code:themes:v1`), so there
            is no themes option here (stylix is not applicable).
          '';
        };

        keybindings = lib.mkOption {
          type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
          default = [ ];
          example = [
            {
              key = "mod+g";
              command = "terminal.toggle";
            }
            {
              key = "mod+shift+g";
              command = "terminal.new";
              when = "terminalFocus";
            }
          ];
          description = ''
            Keybinding rules written to {file}`~/.t3/userdata/keybindings.json`.

            Each rule is `{ key, command, when? }`. The server merges the
            built-in defaults with these rules, preferring a user rule that
            claims a command or shortcut. See
            <https://github.com/pingdotgg/t3code/blob/main/docs/user/keybindings.md>
            for the key syntax and command IDs.
          '';
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

          home.file = {
            ".t3/userdata/settings.json" = lib.mkIf (cfg.settings != { }) {
              source = jsonFormat.generate "t3-code-settings.json" cfg.settings;
            };

            ".t3/userdata/keybindings.json" = lib.mkIf (cfg.keybindings != [ ]) {
              source = jsonFormat.generate "t3-code-keybindings.json" cfg.keybindings;
            };
          };
        })
        (lib.mkIf (cfg.desktop.enable && cfg.desktop.package != null) {
          home.packages = [ cfg.desktop.package ];
        })
      ];
    };
}
