{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gpu-screen-recorder-ui;
  jsonFormat = pkgs.formats.json { };
in
{
  meta.maintainers = [ lib.hm.maintainers.vidhanio ];

  options.programs.gpu-screen-recorder-ui = {
    enable = lib.mkEnableOption "GPU Screen Recorder UI";

    package = lib.mkPackageOption pkgs "gpu-screen-recorder-ui" { nullable = true; };

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
        nested JSON format. Unspecified settings use the application's defaults.

        See the upstream
        [configuration source](https://git.dec05eba.com/gpu-screen-recorder-ui/tree/src/Config.cpp)
        for available settings. Attribute names follow the JSON structure;
        dotted option names in the source correspond to nested attributes.

        When non-empty, these settings produce a read-only configuration file.
        Changes made in the UI are not persisted, and gsr-ui may report a
        warning when it tries to save. Leave this empty to manage settings
        through the UI instead.

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

    xdg.configFile."gpu-screen-recorder/config_ui" = lib.mkIf (cfg.settings != { }) {
      source = jsonFormat.generate "gpu-screen-recorder-ui-config" cfg.settings;
    };
  };
}
