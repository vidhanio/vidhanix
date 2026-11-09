{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gpu-screen-recorder-ui;
  jsonFormat = pkgs.formats.json { };
  configPath = "${config.xdg.configHome}/gpu-screen-recorder/config_ui";
in
{
  meta.maintainers = [ lib.hm.maintainers.vidhanio ];

  options.programs.gpu-screen-recorder-ui = {
    enable = lib.mkEnableOption "GPU Screen Recorder UI";

    package = lib.mkPackageOption pkgs "gpu-screen-recorder-ui" { nullable = true; };

    mutableSettings = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to keep the configuration writable so changes made in the UI
        can be saved. Non-empty {option}`settings` are recursively merged into
        the existing JSON configuration on activation, with Nix-declared
        values taking precedence. Arrays are replaced rather than merged.

        Undeclared settings are preserved. Removing a setting from Nix does
        not remove it from the saved configuration. Empty settings leave the
        file untouched. Stop gsr-ui before activating to avoid concurrent
        writes. Comments and formatting are not preserved.

        When switching back to immutable settings, files with different
        contents are left to Home Manager's normal collision and backup
        handling rather than discarded.
      '';
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        record = {
          container = "mkv";
          record_options = {
            fps = 60;
            record_cursor = true;
          };
        };
        replay.time = 120;
        screenshot = {
          image_format = "png";
          save_screenshot_to_clipboard = true;
        };
      };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/gpu-screen-recorder/config_ui` in gsr-ui's
        nested JSON format. In immutable mode, unspecified settings use the
        application's defaults.

        See the upstream
        [configuration source](https://git.dec05eba.com/gpu-screen-recorder-ui/tree/src/Config.cpp)
        for available settings. Attribute names follow the JSON structure;
        dotted option names in the source correspond to nested attributes.

        Unless {option}`mutableSettings` is enabled, non-empty settings produce
        a read-only configuration file. Changes made in the UI are not
        persisted, and gsr-ui may report a warning when it tries to save.
        Leave this empty to manage settings through the UI instead.

        Do not include stream keys or other secrets: the generated file is
        stored in the world-readable Nix store.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.gpu-screen-recorder-ui" pkgs lib.platforms.linux)
    ];

    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    home.activation = {
      gpuScreenRecorderUiSettings = lib.mkIf (cfg.mutableSettings && cfg.settings != { }) (
        lib.hm.dag.entryAfter [ "linkGeneration" ] (
          lib.hm.generators.mkImpureConfigMerger {
            inherit pkgs;
            format = "json";
            empty = "{}";
            jqOperation = "$dynamic * $static";
            path = configPath;
            staticSettings = jsonFormat.generate "gpu-screen-recorder-ui-config" cfg.settings;
            mode = "600";
          }
        )
      );

      gpuScreenRecorderUiImmutableSettings = lib.mkIf (!cfg.mutableSettings && cfg.settings != { }) (
        lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] (
          lib.hm.generators.mkImpureConfigCleanup {
            file = config.home.file.${configPath};
          }
        )
      );
    };

    xdg.configFile."gpu-screen-recorder/config_ui" =
      lib.mkIf (!cfg.mutableSettings && cfg.settings != { })
        {
          source = jsonFormat.generate "gpu-screen-recorder-ui-config" cfg.settings;
        };
  };
}
